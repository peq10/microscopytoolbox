
acotsp: acotsp.o TSP.o utilities.o ants.o InOut.o timer.o ls.o parse.o
        lcc.exe -ansi acotsp.o TSP.o utilities.o ants.o InOut.o timer.o parse.o ls.o -o acotsp -O -lm 

acotsp.o: acotsp.c
        lcc.exe  -c acotsp.c -o acotsp.o  -O -Wall -ansi -pedantic

TSP.o: TSP.c TSP.h
        lcc.exe -c TSP.c -o TSP.o  -O -Wall -ansi -pedantic

ants.o: ants.c ants.h
        lcc.exe -c ants.c -o ants.o  -O -Wall -ansi -pedantic

InOut.o: InOut.c InOut.h
        lcc.exe -c InOut.c -o InOut.o  -O -Wall -ansi -pedantic

utilities.o: utilities.c utilities.h
        lcc.exe -c utilities.c -o utilities.o  -O -Wall -ansi -pedantic

ls.o: ls.c ls.h
        lcc.exe -c ls.c -o ls.o  -O -Wall -ansi -pedantic

parse.o: parse.c parse.h
        lcc.exe -c parse.c -o parse.o  -O -Wall -ansi -pedantic

timer.o: timer.c timer.h
        lcc.exe -c timer.c -o timer.o  -O -Wall -ansi -pedantic
