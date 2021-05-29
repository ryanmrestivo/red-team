docker build -t sullo/nikto .

# Call it without arguments to display the full help
docker run --rm sullo/nikto

# Basic usage
docker run --rm sullo/nikto -h http://www.example.com