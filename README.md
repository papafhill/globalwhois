# globalwhois
A CLI tool that runs `whois` on an apex domain and finds all Top Level Domains globally.

## Usage
To run the script and print to a `.txt` file:
`bash globalwhois.sh example.com > out.txt`

Easy review of output:
`cat out.txt | grep REGISTERED`
`cat out.txt | grep AVAILABLE`
