# ZeroLogon

Scenario:

Your role as a Tier 2 SOC Analyst at EliteSystems Corp is put to the test following an alert from the Tier 1 team about a confirmed phishing email leading to a potential network wide intrusion. With disk data already triaged and ready for analysis, you must uncover the extent of this intrusion and identify the compromised assets within the network.

![image](https://github.com/user-attachments/assets/6db0399a-b738-4945-8487-74399273d0b9)

Well, looking at the image I can immediately identify this as a spearphishing attempt. 

Red flags in the body of the email:
1. Sense of urgency. "Melenia" is attempting to extort the recipient of this email into downloading and opening the compressed software.
2. Zipped, password-protected, email attachment. This should set off major red flags for analysts, employees should never open password protect zip files downloaded from emails. This is for two reasons:
   * Password-protected zip files are encrypted, so most security tools won't be able to detect the malicious software inside. The intention of this is to ensure the confidentiality and integrity of the file that is sent, however, this can be exploited by threat actors who deliver their initial payloads through encrypted email attachments.
   * Depending on the context of the organization, the security team could create email gateway rules to drop messages with password-protected zip files.
  
# Thunderbird Logs on the Initially Targeted User

![image](https://github.com/user-attachments/assets/6e67ebd2-3354-4632-903c-b45a8c187ccd)

![image](https://github.com/user-attachments/assets/ab0958b6-0801-40e3-afca-b78abf66db1d)

This indicates to me that the original Yahoo mail server that sent the email attachment likely targeted other individuals as well, and that we are on the right track.

I'm going to start with using Eric Zimmerman's LECmd.exe to parse the LNK files in emily's Desktop directory, and output them to a csv file to be imported to TimelineExplorer.

![image](https://github.com/user-attachments/assets/00110521-b412-49d0-bcc6-c5984c235694)

![image](https://github.com/user-attachments/assets/9849e2e0-b008-4441-a2bd-8233a889e785)

It looks like the documents.zip file started in the Downloads folder, nothing too intresting here so far, so I will pivot to Event Logs.

![image](https://github.com/user-attachments/assets/3b112226-43fe-4eb4-8a23-68708416aebb)

This appears to be a malicious executable used for C2 communications, which we will come back to later.

For now, I saw an encoded PowerShell command which I was able to decode using CyberChef.

![image](https://github.com/user-attachments/assets/21db4029-78d9-4a82-8fa5-94c5521c686b)

![image](https://github.com/user-attachments/assets/0b9740f7-dd0e-420c-9ee0-ee87d04d1baa)

As well as a command that downloads and uses the Invoke-ShareFinder module from PowerView.
