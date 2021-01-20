To run fun the flake8 target
```
make flake8
```

To run with docker compose
```
docker-compose run alpine make flake8
```

Comments
--------
Bash build scripts get very complicated, very fast because bash lacks basic programming language
structures.

Make is only somewhat better. Make is a a tool __creates output file from input file when input file is newer than output.__
If the task doesn't fit into that pattern, such as code reformatting, unit test running, then
you have to rely on clever hacks.

Features of this make script
---------------------------
- Skip reformatting & linting if no python file has changed
- Do formatting before linting.
- Do linting before running tests.
- Option to clean pythons compiled files, which normally don't cause a problem.
