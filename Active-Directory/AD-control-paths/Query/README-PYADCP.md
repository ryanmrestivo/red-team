# query.py
Like query.rb, with some improvements

Early stage, tests are welcome

## Differences
- Bolt protocol support
- Neo4j authentication
- Faster
- replacement for `info`, `nodes` and `path` arguments of _query.rb_ are not available yet

## Install
Only Python3 is supported
    
    python3 -m pip install -r requirements.txt

## Usage
    Usage: query.py [OPTIONS] COMMAND [ARGS]...
    
    Options:
      --lang TEXT          Language to use
      --maxdepth INTEGER   maximum length for control paths
      --neo4j TEXT         neo4j connection URI
      --workdir DIRECTORY  Root of ADCP dump directory
      -v, --verbose        Increase verbosity (add more to increase)
      -o, --options TEXT   Extra options to tweak behavior
      --noprompt           Disable application prompt (useful for batches)
      --help               Show this message and exit.
    
    Commands:
      full
      graph
      list_aliases
      search


- `lang` defaults to _en_, only _en_ and _fr_ are available
- `neo4j` defaults to `bolt://localhost`
- `maxdepth` default to 20 (like _query.rb_)
- `workdir`  should be the dump folder named _yyyymmdd_domainname_
- `options` defaults to `+deny`
  - `[+-]deny` 
    - `+` produces the full graph with denied nodes (tagged DENY),
    - `-` remove denied relations and orphan nodes

### Commands
- `list_aliases` list aliases (like _adm_dom_ or _guests_)
- `search [needle]` return the list of node ids and _dn_
- `graph [search] [direction] [outfile]` produces the control graph in json format (usable by OVALI)
- `full [outdir]` produces all graphs in output directory

### Examples
`query.rb --quick` replacement:
 
    python3 query.py --workdir=[path_to dumps] --neo4j=bolt://user:password@localhost graph adm_dom to dump.json

`query.rb --full` replacement:

    python3 query.py --workdir=[path_to dumps] --neo4j=bolt://user:password@localhost full out

## Tests
Some tests are available in the _tests_ folder. They are used by `test_adcp.py` (_unittests_).

All of these tests use 100 nodes (_TEST_0_ to _TEST_99_)
- 1
  - The nodes _TEST_X*_ are GROUP_MEMBER of _TEST_X_
- 2
  - Same as 1
  - _TEST_2_ has a control link (STAND_RIGHT_WRITE_DAC) to _TEST_1_ 
  - All nodes _TEST_*7_ have a DENY (STAND_RIGHT_WRITE_DAC) to _TEST_1_
- 3
  - Same as 2
  - _TEST_3_ has a control link (STAND_RIGHT_WRITE_DAC) to _TEST_2_
  - _TEST_4_ has a control link (STAND_RIGHT_WRITE_DAC) to _TEST_3_
- 4
  - Same as 2
  - All _TEST_i_ have a control link (STAND_RIGHT_WRITE_DAC) to _TEST_i+1_
  - _TEST_9_ has a control link (STAND_RIGHT_WRITE_DAC) to _TEST_1_ (loop)
- 5
  - Same as 1
  - All _TEST_i_ have 5 control links (STAND_RIGHT_WRITE_DAC, STAND_RIGHT_WRITE_OWNER, WRITE_PROP_ALL, FS_RIGHT_WRITEDATA_ADDFILE, FS_RIGHT_APPENDDATA_ADDSUBDIR) to _TEST_i+1_ (no loop)
  - All nodes _TEST_*7_ have a DENY (STAND_RIGHT_WRITE_DAC) to _TEST_1_
  - All nodes _TEST_*8_ have 5 DENY (_same as control links_) to _TEST_1_

Tests can be loaded manually with `tests/load_test.py [load|clean] <test_id>` (n.b. the script must be run from the root folder)