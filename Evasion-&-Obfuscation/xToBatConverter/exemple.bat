@echo off
(
echo -----BEGIN CERTIFICATE-----
echo SGVsbG8gV29ybGQ=
echo -----END CERTIFICATE-----
) >>%cd%\_TEST.txt_.b64

certutil -decode %cd%\_TEST.txt_.b64 "%cd%\TEST.txt"
del %cd%\*_.b64
start %cd%\TEST.txt