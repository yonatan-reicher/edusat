#include "edusat.h"
#include "edusat_incremental.h"
#include "options.h"
#include "cpuTime.h"

template <typename Solver>
void read_and_solve(Solver& s, std::ifstream& in) {
    s.read_cnf(in);
    in.close();
    s.solve();
}

int main(int argc, char** argv) {
	begin_time = cpuTime();
	parse_options(argc, argv);

	ifstream in(argv[argc - 1]);
	if (!in.good()) Abort("cannot read input file", 1);
	cout << "This is edusat" << endl;

    switch (mode) {
    case MODE::NORMAL:
        read_and_solve(edusat::S, in);
        break;
    case MODE::INCREMENTAL:
        read_and_solve(edusat::incremental::S, in);
        break;
    }

	return 0;
}
