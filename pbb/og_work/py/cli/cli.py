import argparse

def cli_args():
    parser = argparse.ArgumentParser(
        description="Process financial aid rules"
    )

    parser.add_argument(
        "-fo", "--file_only",
        action="store_true",
        help="only create single large file rather than new directory"
    )
    parser.add_argument(
        "-t", "--tables",
        action="store_true",
        help="create a sql file for each table an insert is created for"
    )
    parser.add_argument(
        "-y", "--aidy",
        type=int,
        help="Aid year (e.g. 2627)"
    )
    
    parser.add_argument(
        "-o", "--output_file",
        help="specify output file"
    )

    parser.add_argument(
        "-r", "--rules-only",
        dest="rules_only",
        action="store_true",
        help="only generate inserts for RBRABRC"
    )
    
    parser.add_argument(
        "-n", "--no-rules",
        dest="no_rules",
        action="store_true",
        help="generate inserts for all but RBRABRC"
    )
    
    return parser.parse_args()