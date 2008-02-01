--
-- in case that the DB service is stopped (after reboot?) start it using
-- /usr/local/pgsql/bin/postmaster -D /home/rwollman/DBrawFiles
--

----------------------------------------------------------------------------
---- THIS SECTION DEALS WITH DEFENITION OF COLLECTION AND RELATED TABLES ---
----------------------------------------------------------------------------


--
-- collection type provides naming for collections, e.g. a gallery as a collection of cells, 
-- a well as a collection of images etc. 
-- 
--
CREATE TABLE coll_types (
	name varchar primary key, 
	description varchar
);

INSERT INTO coll_types(name,description) values ('Plate','a plate in a screen');
INSERT INTO coll_types(name,description) values ('Well','a well in a screen');
INSERT INTO coll_types(name,description) values ('Unknown','To be determined - collection is undefined in the FD');

--
-- Collection is a set of img sequences (well in a plate, plate in a screen, etc)
-- collections have three goals: 
--     1. to provide some way to order the images
--     2. to create some tagging mechanism for images 
--     3. to cary quantitative information on a collection of images
-- therefore an image could be in many collections and a collection can contain many images
-- also collection (via the col2 table) could include other collections as well)
--
CREATE TABLE collections (
    filename varchar primary key, 
	name varchar,
	type varchar references coll_types (name)
);

CREATE TABLE coll_2 (
	sub varchar references collections(filename),
	dom varchar references collections(filename),
	PRIMARY KEY (sub, dom)
);

--
-- Any collection could have multiple summary statistics, here I define their types
--
CREATE TABLE coll_qdata_types (
	name varchar primary key, 
	description varchar
);

-- in coll_qdata I store any numbers that matter for a collection (summary statsitcs)
--  could be p-values for a well, average cell num per image, etc. 
--
CREATE TABLE coll_qdata (
        id serial PRIMARY KEY, 
	type varchar references coll_qdata_types(name) NOT NULL,
	coll varchar references collections(filename) NOT NULL,
	value numeric[],
	label text
);



--------------------------------------------------------------
---- THIS SECTION DEALS WITH IMAGES, RAW AND PROCESSED -------
--------------------------------------------------------------

-- 
-- img_types contains the type of the image, e.g. raw image, binary mask, label, cell, etc .
-- img_type are important since they are what determine which type of analysis will be performed on these image
-- 

CREATE TABLE img_types (
	name varchar primary key, 
	description varchar
);

--
-- every matrix with data in it is an image!
-- (including edge detection, binary masks, labeled images etc.)
-- the database supports them all under a single table, 
-- therfore there is the img_types to tell them apart
--
INSERT into img_types (name,description) values ('raw','straight from the scope...'); 
INSERT into img_types (name,description) values ('raw 3D-XYC','straight from the scope...'); 
INSERT into img_types (name,description) values ('raw 4D-XYCZ','straight from the scope...'); 
INSERT into img_types (name,description) values ('raw 5D-XYCZT','straight from the scope...'); 
INSERT into img_types (name,description) values ('gallery','a collection of cells');
INSERT into img_types (name,description) values ('cell','an image of a single cell'); 
INSERT into img_types (name,description) values ('edge','edge detection');
INSERT into img_types (name,description) values ('label','labeled image'); 

--
-- an image is a matrix ([2-5]D) with its metadata
-- compresses is a boolean that denote if the image is bz2 compressed
-- filename is the FULL FILE NAME including the path!!!
-- 
CREATE TABLE images (
        filename varchar PRIMARY KEY,
	type varchar references img_types(name),
	compresses boolean default false NOT NULL,
	dim_order char(5),
	dim_size numeric[3],
	pix_type varchar,
	pix_size numeric[3], --- always x y z
	creation_date timestamp, -- when the image was first saved to disk
        last_modified timestamp, -- when the image was last modified
	description text,
	channel_num integer DEFAULT 1 NOT NULL,
	channel_names varchar[],
	channel_description text[],
	img_height numeric, --- This is the height if binning was 1, real height is height/binning no need to save this twice...
	img_width numeric  --- same with width... 
	
);

-- a table to store the metadata of the image for each timepoints
CREATE TABLE timepoints (
        id serial PRIMARY KEY,
	img varchar REFERENCES images(filename) NOT NULL,
	acq_time time,
	stage_x numeric[][],
	stage_y numeric[][],
	stage_z numeric[][],
	exposure_time numeric[][],
	binning numeric[][],
);

-- create a many-many relation between images and collections 
CREATE TABLE img_X_coll (
	img varchar references images(filename),
	coll varchar references collections(filename),
	major boolean DEFAULT false NOT NULL, 
	PRIMARY KEY (img,coll)
);

	
--
-- 
--
CREATE TABLE img_qdata_types (	
	name varchar primary key,
	description varchar
);
	
-- in img_qdata I store any numbers that matter for that image
--  could be its adjustment levels, could be a threshold or whatever	
--
CREATE TABLE img_qdata (
        id serial PRIMARY KEY,
	type varchar references img_qdata_types(name) NOT NULL,
	img varchar references images(filename) NOT NULL,
        value numeric[] NOT NULL, 
	label text
);

CREATE TABLE timepoint_qdata_types (
	name varchar primary key,
	description varchar
);

CREATE TABLE timepoint_qdata (
        id serial PRIMARY KEY,
	type varchar references timepoint_qdata_types(name) NOT NULL,
	timepoint_id integer references timepoints(id) NOT NULL,
        value numeric[] NOT NULL, 
	label text
);


--------------------------------------------------------------
---- THIS SECTION DEALS WITH JOBS TRACKING AND PROCESSING ----
--------------------------------------------------------------

-- This table holds the tables that it is legal to spawn jobs based on
CREATE TABLE job_type_based_on_table ( name varchar primary key );
INSERT into job_type_based_on_table (name) values ('images');
INSERT into job_type_based_on_table (name) values ('collections');
INSERT into job_type_based_on_table (name) values ('img_qdata');
INSERT into job_type_based_on_table (name) values ('coll_qdata');

-- Job type - this table contains the type of analyis that should be performed
-- It has few parts: 
-- part I - id, executable and static argument (static in the sense that they are the same for all jobs.
-- part II - run on view - this is the text of a stored query (that will be used to generate a view) that
--           define on what input_id should the job performed. The query should return a list of ids.
-- part III - dynamic argument - an sql query that will be called to generate the specific input argument for
--            that job, could be as simple as 
CREATE TABLE job_types (
        -- part I 'static data'
	id serial primary key, 
	executable varchar NOT NULL, 
	-- part II - conditions to create a new job
        view_name varchar NOT NULL, 
	run_on_query text NOT NULL, -- this field hold the sql query that defines on whom this job_type should be performed.
                                    -- a trigger on insert will turn it also into a view for ease of use. 
                                    -- the view should have one column named input_id that store a list of input to run on. 
        -- part III - dynamic part of the 
	inputqryfcn varchar -- this is the name of an external function to run that queries the DB and create the inputs for this job
                        -- This function will be run by the JobManager to create the file with all the info 
                        -- for the job, it should be an execulable that runs on the head-node and gets as input
                        -- the input_id from the jobs table. 
                        -- If Null - than the filename is provided as input without any other arguments (including argv)
        run_times integer DEFAULT 1,
        max_simultanious_nodes DEFAULT 1
);

-- Legal Job status
CREATE TABLE job_status (
	status varchar primary key
);

INSERT INTO job_status (status) values ('success');
INSERT INTO job_status (status) values ('error');
INSERT INTO job_status (status) values ('running');
INSERT INTO job_status (status) values ('queue');

--
-- Jobs - some number crunching that needs to be done.
-- Jobs are managed via a dameon (JobManager) and run on a cluster/server
-- for more details on what a Job is, see doc. 
--
CREATE TABLE jobs (
	id serial primary key, 
	job_type_id integer references job_types (id) NOT NULL, 
	status varchar references job_status (status) DEFAULT 'queue' NOT NULL, 
	errormsg text,
	filename varchar NOT NULL -- this could reference either collections, images filename. This would be the input to inputqryfcn 
	                          -- in the job_type table
);

CREATE TABLE job_log (
    id serial primary key,
    job_id integer references jobs (id) NOT NULL,
    status varchar NOT NULL,
    time timestamp DEFAULT CURRENT_TIMESTAMP,
);

------------------------------------------------
-- DATABASE DEFINED FUNCTIONS and TRIGGERS------
------------------------------------------------

--
-- A Trigger and its function to add timestamps to Job on updates
--
--CREATE OR REPLACE FUNCTION timestamp_jobs_func () RETURNS TRIGGER as $$

--# if status changed to running, timestamp the started
--if ($_TD->{new}{status} eq 'running') {$_TD->{new}{started}=CURRENT_TIMESTAMP;}

--# if status changed to success/error, timestamp finished
--if ($_TD->{new}{status} eq 'error') {$_TD->{new}{finished}=CURRENT_TIMESTAMP;}
--if ($_TD->{new}{status} eq 'success') {$_TD->{new}{started}=CURRENT_TIMESTAMP;}

--$$ LANGUAGE plperl;

--CREATE TRIGGER timestamp_jobs_trigger BEFORE UPDATE ON jobs
--FOR EACH ROW EXECUTE PROCEDURE timestamp_jobs_func();


--
-- A trigger that will be called when inserting a new job_type
-- it will create a view based on run_on_query field. 
--                        


--





