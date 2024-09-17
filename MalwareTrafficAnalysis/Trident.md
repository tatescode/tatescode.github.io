# Trident Lab [CyberDefenders]

#### Scenario:

As a soc analyst, a phishing attack attributed to a popular APT group targeted one of your customers. Given the provided PCAP trace, analyze the attack and answer challenge questions.

![image](https://github.com/user-attachments/assets/6d4010cc-450f-4d8d-a278-7b4757335250)

From the conversations view in Wireshark, we can see that there are tons of unique IP addresses sending SYN packets to the 192.168.112.139 endpoint, which is indicative of port scanning using SYN packets.

Now that we know which endpoint is the target of this attack, I'll look for packets containing the SYN/ACK flags turned on in the TCP header, this will give me more of an idea of which open ports have potentially been discovered.

**To detect open ports found by the attacker, I am specifically looking for a tcp stream where:**
1. Attacker [SYN] -> Victim
2. Victim [SYN/ACK] -> Attacker
3. Attacker [ACK] -> Vicim
4. Attacker [RST, ACK] -> Victim

Wireshark Filter: `ip.dst==192.168.112.139 && tcp and tcp.flags == 0x014`

**Following this logic, the following 7 ports are found open on the victim machine:**
- 587 [SMTP]
- 135 [RPC client-server comms]
- 139 [SMB]
- 143 [IMAP]
- 25 [SMTP relaying]
- 445 [NetBIOS]
- 110 [POPv3]

![image](https://github.com/user-attachments/assets/ba347d6d-c834-4ded-aa11-274d956a896a)

**Checking out the TCP stream of the conversation on port 25, we notice a few alarming things:**
1. "EHLO kali"
2. An email message with an urgent call to action.
3. An attached microsoft .docx file with a subsequent blob of base64 encoding.
4. Coming from the internal IP address 192.168.112.128, this SMTP message seems to have been sent from a previously infected machine.

![image](https://github.com/user-attachments/assets/e73a21b5-3265-4b3e-bc3a-1cbad32f8824)

Using NetworkMiner to check out this filer, I see that the real file extension is .zip and the "docx" file extension was only to mask what the file really was.

I will use `7z x 'web server.docx' -owebserver` to unzip the file, and extract the output to a folder named "webserver"

This folder is made up of multiple files and folders, so what I will do is use grep to search these plain text files for any hardcoded ip addresses or URL's.

IP's: ![image](https://github.com/user-attachments/assets/31c382c9-7661-4d7d-81b7-9287e10f01be)

URL's: ![image](https://github.com/user-attachments/assets/96f1ec63-5744-4d8f-9e9c-f3b46d843b49)

Lets check out that html file...



