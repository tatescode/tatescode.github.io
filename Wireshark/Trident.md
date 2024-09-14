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

Following this logic, the following 7 ports are found open on the victim machine:

Wireshark Filter: `ip.dst==192.168.112.139 && tcp.flags.ack==1`

587 [SMTP]

135 [RPC client-server comms]

139 [SMB]

143 [IMAP]

25 [SMTP relaying]

445 [NetBIOS]

110 [POPv3]

![image](https://github.com/user-attachments/assets/ba347d6d-c834-4ded-aa11-274d956a896a)

Checking out the TCP stream of the conversation on port 25, we notice a few alarming things:
1. "EHLO kali"
2. An email message with an urgent call to action.
3. An attached microsoft .docx file with a subsequent blob of base64 encoding.
4. Coming from the internal IP address 192.168.112.128, this SMTP message seems to have been sent from a previously infected machine.
