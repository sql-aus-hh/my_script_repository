rem Open SQL Ports
netsh advfirewall firewall add rule name="SQL Server (TCP 1433)" dir=in action=allow protocol=TCP localport=1433 profile=domain
netsh advfirewall firewall add rule name="SQL Server (TCP 6201)" dir=in action=allow protocol=TCP localport=6201 profile=domain
netsh advfirewall firewall add rule name="SQL Server (TCP 6202)" dir=in action=allow protocol=TCP localport=6202 profile=domain
netsh advfirewall firewall add rule name="SQL Server (TCP 6203)" dir=in action=allow protocol=TCP localport=6203 profile=domain

rem Open AG Ports
netsh advfirewall firewall add rule name="SQL Server - AG (TCP 6221)" dir=in action=allow protocol=TCP localport=6221 profile=domain
netsh advfirewall firewall add rule name="SQL Server - AG (TCP 6222)" dir=in action=allow protocol=TCP localport=6222 profile=domain
netsh advfirewall firewall add rule name="SQL Server - AG (TCP 6223)" dir=in action=allow protocol=TCP localport=6223 profile=domain

rem Open add. SQL Browser Ports
netsh advfirewall firewall add rule name="SQL Service Broker (TCP 4022)" dir=in action=allow protocol=TCP localport=4022 profile=domain
netsh advfirewall firewall add rule name="SQL Browser (UDP 1434)" dir=in action=allow protocol=UDP localport=1434 profile=domain



netsh advfirewall firewall add rule name="SQL Server D365 (TCP 49903)" dir=in action=allow protocol=TCP localport=49903 profile=domain
netsh advfirewall firewall add rule name="SQL Server ITSYS (TCP 49933)" dir=in action=allow protocol=TCP localport=49933 profile=domain
netsh advfirewall firewall add rule name="SQL Server NAV2015 (TCP 49969)" dir=in action=allow protocol=TCP localport=49969 profile=domain
netsh advfirewall firewall add rule name="SQL Server NAV2015ZW (TCP 50012)" dir=in action=allow protocol=TCP localport=50012 profile=domain

netsh advfirewall firewall add rule name="SQL Server D365 AG (TCP 5022)" dir=in action=allow protocol=TCP localport=5022 profile=domain
netsh advfirewall firewall add rule name="SQL Server ITSYS AG (TCP 5025)" dir=in action=allow protocol=TCP localport=5025 profile=domain
netsh advfirewall firewall add rule name="SQL Server NAV2015 AG (TCP 5028)" dir=in action=allow protocol=TCP localport=5028 profile=domain
netsh advfirewall firewall add rule name="SQL Server NAV2015ZW AG (TCP 5031)" dir=in action=allow protocol=TCP localport=5031 profile=domain

netsh advfirewall firewall add rule name="SQL Server D365 AGListener (TCP 6222)" dir=in action=allow protocol=TCP localport=6222 profile=domain
netsh advfirewall firewall add rule name="SQL Server ITSYS AGListener (TCP 6225)" dir=in action=allow protocol=TCP localport=6225 profile=domain
netsh advfirewall firewall add rule name="SQL Server NAV2015 AGListener (TCP 6228)" dir=in action=allow protocol=TCP localport=6228 profile=domain
netsh advfirewall firewall add rule name="SQL Server NAV2015ZW AGListener (TCP 6231)" dir=in action=allow protocol=TCP localport=6231 profile=domain

netsh advfirewall firewall add rule name="SQL Service Broker (TCP 4022)" dir=in action=allow protocol=TCP localport=4022 profile=domain
netsh advfirewall firewall add rule name="SQL Browser (UDP 1434)" dir=in action=allow protocol=UDP localport=1434 profile=domain