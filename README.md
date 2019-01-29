# Bash Audit
Push your bash commands to a influxDb

## Use:
    $ command -w parameters ; audit "a string Comment"

## Requeriments:
* Bash
* Curl
* an InfluxDb instance that we can reach on our shell

## What does it do?
### Problem
Suppose you have a Grafana graph with performance metrics. Sometimes 
track those metrics and the commands you do at the same time can be
tricky. (i.e see how much of a performance hit is a nginx restart)

### Solution
Enter Bash_Audit, alias *audit*, a simple bash script that logs the last
command that you wrote on your bash prompt to a specific influxdb.

Its really simple to use:

    cachosagan@dev-cacho-01:~/bash_audit$ docker-compose -f production.yml up -d ; audit

That command pushes to the influxDb the command (*docker-compose -f 
production.yml up -d* in this case) you wrote. Note the **"; audit"** at 
the end.

At the current configuration of the script, audit pushes:
* Current username (*your* username, no matter if you sudo bash it)
* Hostname
* PWD
* The command
* The optional comment you can pass to audit as a parameter

In theory, as long as you modify the DATABINARY variable, you can expand
with as many things as you want (tags of fields). 

## Setup
In order for this to work, we need to setup a **trap** in our **.bashrc**
(located in you ~) or in the system .bashrc (located in /etc/bash.bashrc)

Traps are your friend. For more info, check the page on traps ([tldp](http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_12_02.html))

We need to setup a DEBUG trap so we can capture all the commands we wrote.
Well, not **all** commands. We really don't need to send to influx when
we use "ls -lah" on a dir, just the ones we want (by using **; audit**)

So we need to cath the important commands. Like this:

### Campos necesarios
```bash
trap 'export last_command=$this_command; this_command=$(echo $BASH_COMMAND|sed "s/\"//g")' DEBUG
alias audit="bash $AUDIT_INSTALL_PATH/audit.sh $last_command "
```
($AUDIT_INSTALL_PATH is where you clone this repo.)

After the change, you can reset your bash with a simple
```bash
reset
```

## Use

After configuring the xinitrc...

````bash
echo Mistry ; audit
````
Can be translated as:

````bash
curl --silent -XPOST 'http://grafana.local:8086/write?db=data' --data-binary 'bash_audit,user=lahire,hostname=myhost command="echo Mistry",comment="",pwd="/home/lahire/bash_audit"
````

Note the empty comment field. When you add a comment:

````bash
echo Mistry ; audit "comment with spaces!"
````
Esto se traduce a 

````bash
curl --silent -XPOST 'http://grafana.local:8086/write?db=data' --data-binary 'bash_audit_testing,user=lahire,hostname=myhost command="echo Mistry",comment="comment with spaces!",pwd="/home/lahire/bash_audit"
````
To learn more about writing data on Influx with the HTTP API, [read here](https://docs.influxdata.com/influxdb/v1.7/guides/writing_data/).

After all this, we will have a measurement on our influx called
*bash_audit* that we can add to our Grafanas as Annotations. To learn
how to add them, you can RTFM [on the Grafana Documentation](http://docs.grafana.org/reference/annotations/)

# Is this useful?
You have no idea. tracking bash commands on a performance graph (or any graph)
proved to be very useful to understand problems and track possible fixes.
Hope it helps you as much as it helped me.
<3