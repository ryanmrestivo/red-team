# Start Prowler
./prowler

# Run Prowler with single standard check
./prowler -c check310

# Monocolored report
./prowler -M mono > prowler-report.txt
or if you want a coloured HTML report do:

# Colored report
./prowler | ansi2html -la > report.html