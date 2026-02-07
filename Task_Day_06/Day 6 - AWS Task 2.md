Task Description:

Set up a VPC with an Internet gateway, create a public subnet with 256 IP addresses, a private subnet with 256 IP addresses, make a route table connecting the Internet gateway and the subnets, and launch a Linux EC2 instance by using the above VPC and public subnet.

**Solution :**

**Step 1: Creating a VPC**

Using the IP range 10.0.0.0/16 for this VPC
![[Pasted image 20260208003846.png]]

**Step 2: Creating Subnets**

for Public IP address which needs 256 IP, which can be calculated as 2^8 = 256, I am using 10.0.1.0/24
![[Pasted image 20260208004356.png]]
![[Pasted image 20260208004421.png]]

**Step 3: Creating Internet Gateway**

![[Pasted image 20260208004521.png]]

**Step 4: Attaching the created Internet Gateway to the VPC**

![[Pasted image 20260208004617.png]]

**Step 5: Creating Route Table**

![[Pasted image 20260208004815.png]]

**Step 6: Adding Internet Gateway to the Route Table**

![[Pasted image 20260208005031.png]]

**Step 7: Adding the Public IP subnet to the Route Table**

![[Pasted image 20260208005204.png]]

**Step 8: Creating an EC2 Instance using the new VPC and Subnets created now**

![[Pasted image 20260208010125.png]]
![[Pasted image 20260208010236.png]]
![[Pasted image 20260208010308.png]]

Code:

#!/bin/bash
set -e

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y apache2

systemctl enable apache2
systemctl start apache2

if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "active"; then
    ufw allow 'Apache'
fi

cat <<'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Random Background</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            min-height: 100vh;
            display: grid;
            place-items: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #000000;
            transition: background-color 0.4s ease;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            padding: 40px;
            border-radius: 20px;
            text-align: center;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
        }
        .text {
            font-size: 32px;
            font-weight: bold;
            color: #ffffff;
            margin-bottom: 24px;
            text-transform: uppercase;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
        }
        button {
            padding: 12px 24px;
            font-size: 16px;
            border: none;
            border-radius: 50px;
            cursor: pointer;
            font-weight: 600;
            background: #ffffff;
            color: #000000;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
            transition: all 0.2s ease;
        }
        button:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,0.3); }
        button:active { transform: translateY(0); }
    </style>
</head>
<body>
    <div class="container">
        <div class="text">#000000</div>
        <button type="button" onclick="color()">Change Color</button>
    </div>
    <script>
        function color() {
            const randomColor = Math.floor(Math.random() * 16777215).toString(16).padStart(6, '0');
            const hex = "#" + randomColor;
            document.body.style.backgroundColor = hex;
            document.querySelector(".text").innerText = hex;
        }
    </script>
</body>
</html>
EOF

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
rm -f /var/www/html/index.nginx-debian.html

systemctl restart apache2


**Final Output:**

![[Pasted image 20260208011105.png]]
![[Pasted image 20260208011243.png]]

**IP: 13.235.81.209**

**Result:** 

![[Pasted image 20260208011200.png]]
