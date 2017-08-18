PROGS = orte_no_op mpi_no_op mpi_memprobe

all: $(PROGS)

CFLAGS = -O0 -g

orte_no_op: orte_no_op.c
	ortecc -o orte_no_op orte_no_op.c $(CFLAGS)

mpi_no_op: mpi_no_op.c
	mpicc -o mpi_no_op mpi_no_op.c $(CFLAGS)

mpi_memprobe: mpi_memprobe.c
	mpicc -o mpi_memprobe mpi_memprobe.c -lopen-pal -lopen-rte $(CFLAGS)

clean:
	rm -f $(PROGS) *~
