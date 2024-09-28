# Elastic SIEM

### On November 8th, 2022, an executable was launched from the 'Downloads' folder of a domain user. What is the imphash of that executable?

![image](https://github.com/user-attachments/assets/19219e21-640e-48b9-989c-0d3bff4b2c62)

> Using a simple query for process execution events in the Downloads directory, I see that a 'moviedownloader.exe' was downloaded from the internet, and subsequently used to execute PowerShell once the executable is launched. This is likely the process we are looking for.
>
> The ATT&CK technique this maps to is **T1204.002: User Execution: Malicious File**

> Running this imphash in HybridAnalysis, I confirm this executable's malicious nature.

### What process was responsible for downloading the previously mentioned executable?

> This was found in our previous answer, which is msedge.exe - indicating that this file was downloaded from the internet.

### To maintain persistence, the APT placed a backdoor on the cmurfy endpoint using registry run keys. What is the full registry path used for this persistence mechanism?

![image](https://github.com/user-attachments/assets/77d8f40a-b6ff-438c-ac95-68640a7d9fa2)

> Querying for edited registry Run keys within the HKCU (HKEY_CURRENT_USER) hive, I see that PowerShell made edits to the 'Run\Updater' value. This ensures that the attacker's method of persistence is executed every time cmurfy logs in.

> So far, the attacker has persistence established, now we will look for credential compromise and lateral movement.

### A malicious .bat file was executed on the compromised endpoint, allowing the APT to further control the system and escalate privileges. What is the full path of this .bat file?

![image](https://github.com/user-attachments/assets/a8c6c681-d2c6-46f7-86ca-5a83b70c80ca)

> To find this, I simply queried for process execution events where the executable file was a batch file.

> It looks like the 'update.bat' is used to download and execute a powershell payload in memory, likely to escalate priveleges.
>
> Decoding the payload, it seems to be from PowerEmpire.

### Following the execution of the .bat file, a PowerShell process with PID 7932 was launched. Based on this PID, what is the URL of the malicious file the attacker downloaded onto the compromised endpoint?

> This was the PowerShell payload we found in the previous question.

### Four days after the initial compromise, the APT group began to interact extensively with the compromised endpoint using PowerShell (PID: 6024). What was the 'IntegrityLevel' of the first PowerShell encoded command that was executed?

> The integrity level of the first PowerShell command executed by pid 6024 was 'High", indicating successful privilege escalation.

### On November 13, 2022 @ 08:49:56.217, the APT compromised the Domain Controller (dc-01) by remotely installing a service using a Sysinternals remote administration tool. What was the name of the installed service?

![image](https://github.com/user-attachments/assets/83571093-b343-4bc0-aeaf-fb31b2a828bb)

![image](https://github.com/user-attachments/assets/1c9c5242-188a-40b6-a236-c72d9e7d3ffd)

> PSEXESVC is installed on dc-01. 

### By examining the initially compromised endpoint, we traced the attacker's interactions with the Domain Controller through the command line. What is the domain admin password that was used?

![image](https://github.com/user-attachments/assets/cab19b34-0874-42bf-8b93-92df41c9e17f)

### Using the imphash of the executable identified in previous questions, what .NET C2 framework did the APT initially use? Feel free to search online for assistance.

> I actually found this on question one, by looking up the imphash in HybridAnalysis I found this was related to the Covenant C2 framework. Covenant is a cross-platform post-exploitation framework that support .NET core.

### Here is the attack timeline based on the ATT&CK framework:

**User Execution: Malicious File (T1204.002)**

> Description: An executable was launched from the Downloads folder by a domain user, indicating that the user executed a malicious file.

**Web Service (T1071.001)**

> Description: The executable (moviedownloader.exe) was downloaded via msedge.exe, which indicates the use of a web service for downloading files.

**Registry Run Keys / Startup Folder (T1547.001)**

> Description: A backdoor was placed using registry run keys (HKCU\Software\Microsoft\Windows\CurrentVersion\Run\Updater) to maintain persistence.

**Command and Scripting Interpreter: Batch (T1059.004)**

> Description: The execution of a malicious .bat file (update.bat) that downloads and executes a PowerShell payload.

**Command and Scripting Interpreter: PowerShell (T1059.001)**

> Description: A PowerShell process was launched following the .bat file execution, indicating the use of PowerShell for malicious actions.

**Process Injection (T1055)**

> Description: Although not explicitly mentioned, using PowerShell to download and execute payloads often involves process injection techniques.

**Privilege Escalation (T1068)**

> Description: The initial use of PowerShell and the detection of high integrity level commands suggest successful privilege escalation.

**Service Execution (T1035)**

> Description: The installation of the PSEXESVC service on the Domain Controller indicates service execution for persistence or control.

**Credential Dumping (T1003)**

> Description: Tracing the attacker's interactions and obtaining the domain admin password relates to techniques for credential dumping.

**Command and Control (C2) (T1071)**

> Description: The use of the Covenant C2 framework indicates the establishment of a command and control mechanism for ongoing communication.
