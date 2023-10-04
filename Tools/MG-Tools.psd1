<#
backups
    working on creating backup script

updates
    not working on anything to automate the update process

tools
    collect failed login attempts
    collect and automatically manage RDC connections
    update computer account with owner details using logged in user info and vice versa
    gp discovery, backup, and deploy
    file permission checker for elaborate file systems with plug and play txt files for expected permissions (potentially create it based on user submission on first run).
    start and manage sessions as services with retry atttempts, (hopefully) session injection, and error handling of any sort
    create output of update status of windows machines on the network.
    build out mass output for org that could be called upon for review (possibly displayed on web server).
        includes updates, uptime, storage usage, service uptime, backup status

api automation
    proxmox

azure tools

RMM
    create different scope scenarios for querying devices through winrm
    create service alerts
#>  


<#          LAB hardware
    MINI_PC
        8c 16gb
            2c 6gb -- vm-dom         ## CRITICAL
            2c 2gb -- vm-sql         ## CRITICAL
            4c 8gb -- vm-tool_box    ## High

    BOX_PC
        8c 32gb
            4c 16gb -- vm-MC         ## NON
            2c  8gb -- vm-backup


#>