<div align="center">

# 🤖 Mirza Bot

### A powerful Telegram bot for selling VPN services — with fully automated config creation.

<p>
  <a href="https://t.me/mirzapanel">
    <img src="https://img.shields.io/badge/Telegram-Channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white" alt="Telegram Channel"/>
  </a>
  <a href="https://t.me/mirzapanelgroup">
    <img src="https://img.shields.io/badge/Telegram-Group-229ED9?style=for-the-badge&logo=telegram&logoColor=white" alt="Telegram Group"/>
  </a>
  <a href="https://mirzabot.com/docs/">
    <img src="https://img.shields.io/badge/Docs-mirzabot.com-38BDF8?style=for-the-badge&logo=readthedocs&logoColor=white" alt="Documentation"/>
  </a>
</p>

<p>
  <a href="https://github.com/mahdiMGF2/mirzabot/stargazers">
    <img src="https://img.shields.io/github/stars/mahdiMGF2/mirzabot?style=flat-square&color=f5c518" alt="Stars"/>
  </a>
  <a href="https://github.com/mahdiMGF2/mirzabot/network/members">
    <img src="https://img.shields.io/github/forks/mahdiMGF2/mirzabot?style=flat-square" alt="Forks"/>
  </a>
  <a href="https://github.com/mahdiMGF2/mirzabot/issues">
    <img src="https://img.shields.io/github/issues/mahdiMGF2/mirzabot?style=flat-square" alt="Issues"/>
  </a>
  <a href="https://github.com/mahdiMGF2/mirzabot/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/mahdiMGF2/mirzabot?style=flat-square" alt="License"/>
  </a>
  <img src="https://img.shields.io/badge/PHP-8.5.12%2B-777BB4?style=flat-square&logo=php&logoColor=white" alt="PHP 8.5.12+"/>
</p>

</div>

---

## 📚 Table of Contents

- [✨ Overview](#-overview)
- [📖 Documentation](#-documentation)
- [🧩 Supported Panels](#-supported-panels)
- [💳 Payment Gateways](#-payment-gateways)
- [⚙️ Features](#️-features)
- [🚀 Installation](#-installation)
  - [⚡ Easy Installer (no domain needed)](#-easy-installer-recommended--no-domain-needed)
  - [📘 آموزش نصب آسان ۰ تا ۱۰۰ (فارسی)](#easy-install-fa)
  - [Classic installer (domain required)](#classic-installer-domain-required)
  - [Prerequisites](#prerequisites)
  - [Install](#install)
  - [Update](#update)
  - [Remove](#remove)
  - [Non-Interactive (CLI) Usage](#non-interactive-cli-usage)
- [💎 Free vs. Pro](#-free-vs-pro)
- [🌍 Languages](#-languages)
- [💵 Support the Project](#-support-the-project)
- [👥 Contributors](#-contributors)

---

## ✨ Overview

**Mirza Bot** is a feature-rich Telegram bot for selling VPN subscriptions and automating the entire sales workflow — from purchase and payment to config creation and service management.

It connects directly to your panels, builds configurations automatically, accepts a wide range of payment methods, and gives both customers and admins a clean experience through a **Telegram Mini App** and a **web admin panel**.

> Whether you're handing out trial accounts or running a large-scale reseller business, Mirza Bot has the tools to run it end to end.

---

## 📖 Documentation

The complete user manual lives at **[mirzabot.com/docs](https://mirzabot.com/docs/)** — 61 pages covering every part of the bot, written in **Persian (فارسی)**.

It is not a feature list: every menu is documented with the exact order of the steps the bot asks for, what each field accepts, the error message you get when it rejects your input, and the mistake that most often breaks that feature.

| Section | What it covers |
|---------|----------------|
| **شروع** (Getting started) | Architecture, requirements, server install, shared-host install, CLI flags, updating and removing |
| **ساختار** (Structure) | Repository layout, database tables, which file does what |
| **پنل‌ها** (Panels) | Adding each of the 13 panel types, protocol & inbound setup, per-panel menus, manual config creation, node management |
| **فروشگاه** (Shop) | Products, categories, trial accounts, On-Hold services, bulk purchase, manual sale, renewals and location changes |
| **پرداخت** (Payments) | Card-to-card with receipt approval, every online and crypto gateway, wallet and refunds |
| **مدیریت** (Administration) | Admin roles, feature switches, report channel and topics, texts, forced-join channel, web panel |
| **رشد و بازاریابی** (Growth) | Referrals, cashback, discount and gift codes, lottery and wheel, reseller system |
| **نگهداری** (Operations) | Cron jobs, backup and restore, optimization, security checklist, troubleshooting |

> The docs are generated from the bot's own source, so menu names, limits and error strings match the code rather than an older release.

---

## 🧩 Supported Panels

Mirza Bot integrates with the most popular VPN and network management panels:

| Panel | Panel |
|-------|-------|
| 🟢 **Marzban** | 🟢 **Marzneshin** |
| 🟢 **Sanaei / Alireza** |
| 🟢 **S-UI** | 🟢 **Hiddify** |
| 🟢 **WGDashboard** (WireGuard) | 🟢 **MikroTik** |
| 🟢 **IBSng** | 🟢 **Pasarguard** |

> Configs are generated automatically and are compatible with all common protocols.

---

## 💳 Payment Gateways

| Gateway | Type |
|---------|------|
| 💵 **Card-to-Card** | Manual (receipt + admin approval) |
| 🪙 **NowPayments** | Crypto |
| 🪙 **Plisio** | Crypto |
| 🪙 **CubePay** | TRON / crypto |
| 🇮🇷 **Zarinpal** | Online gateway |
| 🇮🇷 **Aqayepardakht** | Online gateway |
| 🇮🇷 **IranPay** | Online gateway |

---

## ⚙️ Features

### 🛒 Sales & Configuration
- ✅ VPN purchase with **fully automated** config creation
- ✅ Trial / test accounts for new users
- ✅ Compatibility with all common protocols
- ✅ QR codes for fast config import
- ✅ Protocol-based configuration settings
- ✅ Product, panel & gateway management

### 👤 User Experience
- ✅ **Telegram Mini App** for a modern, in-app interface
- ✅ View & manage purchased services:
  - Renew a service
  - Buy additional volume
  - Retrieve config / update subscription links
- ✅ Wallet & balance system
- ✅ Detailed purchase & trial reports
- ✅ Support section, FAQ & customizable tutorials
- ✅ Phone-number verification
- ✅ Mandatory channel membership for purchases

### 📈 Growth & Marketing
- ✅ Affiliate / referral system
- ✅ Cashback rewards
- ✅ Discount codes
- ✅ Gift codes
- ✅ Lottery system
- ✅ **Agent / reseller** system

### 🛠️ Administration
- ✅ **Web admin panel** (login-protected dashboard)
- ✅ Multiple admins support
- ✅ Balance & user management
- ✅ Full text/message customization from the bot
- ✅ Configurable username-generation methods
- ✅ Automatic backups
- ✅ Notification & expiry-reminder services (cron)
- ✅ On-hold configurations

---

## 🚀 Installation

### ⚡ Easy Installer (recommended — **no domain needed**)

`easy-install.sh` installs, updates, repairs, backs up and removes Mirza Bot on a clean **Ubuntu 22.04 / 24.04** or **Debian 12 / 13** server. It asks only for your **bot token** and **Telegram ID** — everything else (PHP 8.5, Apache, MySQL, database, SSL, cron, webhook) is automatic.

Run as **root**:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kiarash707/mirzabot.kia/main/easy-install.sh)
```

After the first run the tool is available everywhere as the **`mirzabot`** command.

| Feature | Details |
|---------|---------|
| 🌐 **No domain required** | Gets a trusted HTTPS address on its own: a free Let's Encrypt **IP-address certificate** → falls back to **`<ip>.sslip.io`** → **`<ip>.nip.io`**. Your own domain is optional (`--domain`). |
| 📦 **Install** | Validates the token with Telegram, installs the whole stack, creates a random database + user, writes `config.php`, registers the webhook and cron jobs. Safe to re-run after an interruption. |
| 🔄 **Update** | Automatic backup first → new version → database migrations → **automatic rollback** if anything fails. Your `config.php`, storage, language overrides and agent bots are preserved. |
| 🗑️ **Remove** | Typed confirmation, optional final backup, removes webhook / cron / site / certificate / database. Never purges packages that existed before the installer (unless `--purge-stack`). |
| 💾 **Backup / Restore** | Database + files in one command, safety backup before every restore. |
| 🩺 **Status** | Services, PHP version, cron, SSL days left, Telegram webhook errors, HTTPS health. |
| ⚙️ **Settings** | Change bot token, admin ID or address (domain ⇄ automatic) later. |

```text
mirzabot                  interactive menu
mirzabot install          install
mirzabot update           update (backup + rollback)
mirzabot remove           uninstall
mirzabot status           health check
mirzabot backup           back up database + files
mirzabot restore          restore a backup
mirzabot reconfigure      change token / admin / address
mirzabot ssl [renew]      SSL status / force renewal
mirzabot webhook [fix]    show / repair the Telegram webhook
mirzabot logs             bot / Apache / installer logs
mirzabot help             all options
```

Non-interactive example:

```bash
mirzabot install --token 123456789:AAxxxxxxxx --admin 11111111 --yes
mirzabot install --token 123456789:AAxxxxxxxx --admin 11111111 --domain bot.example.com --yes
```

📘 **Full step-by-step guide (Persian, from zero to a running bot):** [آموزش نصب آسان ۰ تا ۱۰۰](#easy-install-fa)

### Classic installer (domain required)

The sections below document the original `install.sh`. It requires a domain name and a clean server. **Do not mix it with the Easy Installer on the same server.**

### Prerequisites

| Requirement | Details |
|-------------|---------|
| 🖥️ **OS** | A **clean** Ubuntu **22.04** or **24.04** server |
| 🌐 **Domain** | A domain name pointed to your server's IP |
| ⚙️ **Stack** | PHP 8.5.12+, Apache, MySQL, SSL — *installed automatically by the script* |

> 💡 Start from a fresh server with no existing web server, database, or panel installed.

### Install

Run the following command on your server as **root**:

```bash
curl -o install.sh -L https://raw.githubusercontent.com/mahdiMGF2/mirzabot/main/install.sh && bash install.sh
```

An interactive menu will appear:

```
1) Install Mirza
2) Update Mirza
3) Remove Mirza
4) Migrate: Free → Pro (Beta)
5) Renew SSL certificate
6) Help & Parameters
7) Exit
```

➡️ Select **`1`** to install the bot, then follow the prompts.

### Update

Run the same command and select **`2`**:

```bash
curl -o install.sh -L https://raw.githubusercontent.com/mahdiMGF2/mirzabot/main/install.sh && bash install.sh
```

### Remove

Run the same command and select **`3`** to completely remove the bot and its services.

### Non-Interactive (CLI) Usage

You can also drive the installer entirely from the command line — handy for automation and scripted deployments.

**Commands**

| Command | Description |
|---------|-------------|
| `install` | Install Mirza |
| `update` | Update Mirza (choose channel / version) |
| `remove` | Remove Mirza and its services |
| `migrate` | Migrate Free → Pro |
| `renew` | Renew the bot's SSL certificate |
| `menu` | Open the interactive panel (default) |

**Install parameters**

| Parameter | Description |
|-----------|-------------|
| `--name` | Bot username |
| `--token` | Telegram bot token |
| `--admin` | Admin chat ID |
| `--domain` | Domain name (e.g. `bot.example.com`) |
| `--db-user` | Database username |
| `--db-pass` | Database password |
| `--version` | Specific release tag (e.g. `0.1.7`) |
| `--channel` | `beta` · `release` · `auto` |
| `-h`, `--help` | Show CLI help and exit |

**Examples**

```bash
# Auto-pick the best channel
mirza install --channel auto

# Fully non-interactive install
mirza install --name myvpnbot --token 123:ABC \
              --admin 111 --domain bot.example.com --version 0.1.7

# Update to a specific version or channel
mirza update --version 0.1.6
mirza update --channel release

# Remove
mirza remove
```

---

<a id="easy-install-fa"></a>

## 📘 آموزش نصب آسان ۰ تا ۱۰۰

<div dir="rtl">

این راهنما شما را از **صفر** (حتی بدون سرور و بدون ربات) تا **یک ربات فروش آنلاین و کامل** همراهی می‌کند. لازم نیست دامنه داشته باشید و لازم نیست چیزی از لینوکس بدانید؛ فقط چند دستور را کپی و پیست می‌کنید.

### 🧭 فهرست مراحل

1. [این نصب‌کننده دقیقاً چه کار می‌کند؟](#fa-1)
2. [پیش‌نیازها](#fa-2)
3. [مرحله ۱ — آماده‌کردن سرور](#fa-3)
4. [مرحله ۲ — ساخت ربات و گرفتن توکن](#fa-4)
5. [مرحله ۳ — گرفتن آیدی عددی خودتان](#fa-5)
6. [مرحله ۴ — اتصال به سرور (SSH)](#fa-6)
7. [مرحله ۵ — اجرای نصب](#fa-7)
8. [مرحله ۶ — شروع ربات](#fa-8)
9. [«بدون دامنه» چطور کار می‌کند؟](#fa-9)
10. [مدیریت ربات بعد از نصب](#fa-10)
11. [آپدیت](#fa-11)
12. [بکاپ و بازیابی](#fa-12)
13. [حذف کامل](#fa-13)
14. [نصب بدون سؤال (برای حرفه‌ای‌ها)](#fa-14)
15. [فایل‌ها و مسیرها](#fa-15)
16. [عیب‌یابی](#fa-16)
17. [سؤالات پرتکرار](#fa-17)
18. [نکات امنیتی](#fa-18)

---

<a id="fa-1"></a>

### ۱. این نصب‌کننده دقیقاً چه کار می‌کند؟

با یک دستور، همهٔ این کارها **خودکار** انجام می‌شود:

| # | کار | توضیح |
|---|-----|-------|
| ۱ | بررسی سرور | سیستم‌عامل، رم، فضای دیسک، دسترسی به گیت‌هاب و تلگرام، آزاد بودن پورت‌های ۸۰ و ۴۴۳ |
| ۲ | بررسی توکن | توکن را همان لحظه از تلگرام تأیید می‌کند و نام کاربری ربات را خودش پیدا می‌کند |
| ۳ | نصب PHP 8.5 | ربات به PHP نسخهٔ **۸.۵.۱۲ یا بالاتر** نیاز دارد؛ نصب‌کننده از مخزن معتبر Ondrej/Sury نصبش می‌کند |
| ۴ | نصب Apache و MySQL | به‌همراه همهٔ اکستنشن‌های لازم |
| ۵ | ساخت دیتابیس | با نام، کاربر و **رمز تصادفی و قوی** (چیزی از شما نمی‌پرسد) |
| ۶ | دانلود و نصب ربات | از همین مخزن + نصب کتابخانه‌ها با Composer |
| ۷ | **HTTPS بدون دامنه** | گواهی SSL معتبر و رایگان می‌گیرد (توضیح کامل در [بخش ۹](#fa-9)) |
| ۸ | تنظیم ربات | فایل `config.php`، ساخت جدول‌ها، ثبت وب‌هوک تلگرام |
| ۹ | کرون‌جاب‌ها | کارهای زمان‌بندی‌شدهٔ ربات (تمدید، اعلان‌ها، بکاپ و...) را ثبت می‌کند |
| ۱۰ | امن‌سازی | فایروال (اگر ufw فعال باشد)، تمدید خودکار SSL، لاگ‌گردانی |
| ۱۱ | دستور `mirzabot` | برای مدیریت آسان بعد از نصب (آپدیت، بکاپ، وضعیت، حذف و...) |

> ⏱️ کل نصب روی یک سرور معمولی حدود **۵ تا ۱۰ دقیقه** طول می‌کشد.

---

<a id="fa-2"></a>

### ۲. پیش‌نیازها

| مورد | مقدار پیشنهادی |
|------|----------------|
| 🖥️ **سیستم‌عامل** | Ubuntu **22.04** یا **24.04** (پیشنهاد اصلی) — Debian 12 و 13 هم پشتیبانی می‌شود |
| 🧠 **رم** | حداقل ۱ گیگابایت (روی سرور کم‌رم‌تر، خودکار Swap ساخته می‌شود) |
| 💽 **فضای دیسک** | حداقل ۲ گیگابایت خالی (۱۰ گیگ یا بیشتر پیشنهاد می‌شود) |
| 🌍 **موقعیت سرور** | **خارج از ایران** (سرور باید به `api.telegram.org` دسترسی داشته باشد) |
| 🌐 **IP** | یک IPv4 عمومی (سرور فقط‌IPv6 یا پشت NAT خصوصی پشتیبانی نمی‌شود) |
| 🔓 **پورت‌ها** | ۸۰ و ۴۴۳ باید باز باشند (در پنل فایروال سرویس‌دهنده هم) |
| 👤 **دسترسی** | کاربر `root` |
| 🌐 **دامنه** | **لازم نیست** ✅ |

> ⚠️ از یک سرور **تمیز و تازه** استفاده کنید. اگر روی سرور وب‌سرور دیگری (مثل Nginx روی پورت ۸۰/۴۴۳) یا پنل دیگری نصب است، نصب‌کننده با پیام واضح متوقف می‌شود تا چیزی خراب نشود.

---

<a id="fa-3"></a>

### ۳. مرحله ۱ — آماده‌کردن سرور

1. از یک سرویس‌دهندهٔ VPS معتبر (Hetzner، DigitalOcean، Vultr، Contabo، OVH و...) یک **VPS** بخرید.
2. هنگام ساخت سرور، سیستم‌عامل را **Ubuntu 24.04** (یا 22.04) انتخاب کنید.
3. بعد از ساخت، سرویس‌دهنده به شما سه چیز می‌دهد: **آدرس IP**، **نام کاربری** (معمولاً `root`) و **رمز عبور** (یا کلید SSH). این‌ها را نگه دارید.
4. اگر سرویس‌دهنده فایروال جداگانه دارد (مثل Security Group / Cloud Firewall)، پورت‌های **22، 80 و 443** را باز کنید.

---

<a id="fa-4"></a>

### ۴. مرحله ۲ — ساخت ربات و گرفتن توکن

1. در تلگرام به **[@BotFather](https://t.me/BotFather)** بروید و `/start` بزنید.
2. دستور `/newbot` را بفرستید.
3. یک **نام نمایشی** برای ربات بنویسید (مثلاً: `فروشگاه VPN من`).
4. یک **نام کاربری** بنویسید که حتماً به `bot` ختم شود (مثلاً: `myshop_vpn_bot`).
5. BotFather یک پیام می‌فرستد که **توکن** در آن است، شبیه این:

```text
123456789:AAHxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

6. این توکن را کپی کنید. **آن را به هیچ‌کس ندهید**؛ هر کس توکن را داشته باشد، ربات شما را کنترل می‌کند.

---

<a id="fa-5"></a>

### ۵. مرحله ۳ — گرفتن آیدی عددی خودتان

ربات باید بداند «مدیر اصلی» چه کسی است. برای این کار آیدی **عددی** حساب تلگرام خودتان لازم است (نه username):

1. به **[@userinfobot](https://t.me/userinfobot)** بروید و `/start` بزنید.
2. عددی که در `Id:` نوشته، آیدی شماست؛ مثلاً `123456789`. آن را کپی کنید.

---

<a id="fa-6"></a>

### ۶. مرحله ۴ — اتصال به سرور (SSH)

**ویندوز ۱۰/۱۱:** برنامهٔ **Terminal** یا **PowerShell** را باز کنید و بنویسید (به‌جای `IP-SERVER` آی‌پی سرورتان را بگذارید):

```bash
ssh root@IP-SERVER
```

**مک و لینوکس:** برنامهٔ Terminal را باز کنید و همین دستور را بزنید.

- بار اول می‌پرسد `Are you sure you want to continue connecting?` ← بنویسید `yes` و Enter بزنید.
- رمز را که وارد می‌کنید **چیزی روی صفحه دیده نمی‌شود**؛ این طبیعی است. فقط پیست کنید و Enter بزنید.
- اگر در نهایت چیزی شبیه `root@...:~#` دیدید، وارد شده‌اید ✅

> اگر از ویندوز قدیمی استفاده می‌کنید، برنامهٔ رایگان [PuTTY](https://www.putty.org/) همین کار را می‌کند.

---

<a id="fa-7"></a>

### ۷. مرحله ۵ — اجرای نصب

این **تنها دستور** لازم است. آن را کپی کنید، در ترمینال سرور پیست کنید و Enter بزنید:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kiarash707/mirzabot.kia/main/easy-install.sh)
```

یک منو باز می‌شود:

```text
    1) Install Mirza Bot
    2) Update
    3) Remove
    4) Status & health check
    5) Backup
    6) Restore a backup
    7) Settings  (token / admin / address)
    8) SSL certificate
    9) Repair Telegram webhook
    10) View logs
    0) Exit
```

عدد **`1`** را بزنید و Enter کنید. حالا نصب‌کننده فقط **سه چیز** از شما می‌پرسد:

**۱) توکن ربات** — همان که از BotFather گرفتید را پیست کنید. نصب‌کننده همان لحظه از تلگرام چک می‌کند؛ اگر اشتباه باشد دوباره می‌پرسد.

```text
  ? Telegram bot token (from @BotFather): 123456789:AAHxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ✔ Token accepted - bot is @myshop_vpn_bot
```

**۲) آیدی عددی ادمین** — همان عددی که از `@userinfobot` گرفتید.

```text
  ? Your numeric Telegram ID (admin): 123456789
  ✔ Admin ID: 123456789
```

**۳) نحوهٔ دسترسی (آدرس ربات)**

```text
    1) Automatic - no domain needed (recommended)
    2) I have my own domain
  ? Choose [1]:
```

- فقط **Enter** بزنید (یا `1`) ← **بدون دامنه** ✅ (پیشنهاد اصلی)
- اگر دامنه دارید، `2` را بزنید و دامنه را بنویسید (مثلاً `bot.example.com`). قبلش باید در DNS دامنه یک رکورد **A** به IP سرور بسازید.

بعد از نمایش خلاصه، از شما می‌پرسد `Start the installation? [Y/n]` ← **Enter** بزنید.

حالا بنشینید و تماشا کنید ☕. مراحل با نوار پیشرفت نمایش داده می‌شود:

```text
[1/11] Checking your server
[2/11] Bot details
[3/11] Preparing the system
[4/11] Installing PHP 8.5
[5/11] Installing Apache and the database server
[6/11] Downloading Mirza Bot
[7/11] Creating the database
[8/11] Setting up HTTPS (no domain needed)
[9/11] Configuring the bot
[10/11] Background jobs, firewall and services
[11/11] Final checks
```

در پایان چنین صفحه‌ای می‌بینید:

```text
  ✔ Mirza Bot is installed!
  Bot              https://t.me/myshop_vpn_bot
  Next step        Open the bot, press Start, then send /start
  Address          https://203.0.113.10
  Bot files        /var/www/mirzabot
  Database         mirza_a1b2c3  (user: mirza_d4e5f6)
  DB password      ********************************
  Saved in         /etc/mirzabot/installer.conf (root only)
```

> 🔐 **اطلاعات دیتابیس** را یک‌جا و امن ذخیره کنید. این اطلاعات در `/etc/mirzabot/installer.conf` هم (فقط برای root) نگه‌داری می‌شود.

---

<a id="fa-8"></a>

### ۸. مرحله ۶ — شروع ربات

1. در تلگرام به ربات خودتان بروید (لینک `https://t.me/...` که در پایان نصب نمایش داده شد).
2. دکمهٔ **Start** را بزنید.
3. دستور `/start` را بفرستید؛ چون شما ادمین هستید، **پنل مدیریت** باز می‌شود.
4. از همان‌جا پنل‌ها (مرزبان، سنایی و...)، محصولات، درگاه‌های پرداخت و متن‌ها را تنظیم کنید. راهنمای کامل همهٔ منوها: [mirzabot.com/docs](https://mirzabot.com/docs/)

> 💡 نصب‌کننده در پایان یک پیام تأیید برای ادمین می‌فرستد. اگر قبلاً Start نزده بودید، تلگرام اجازه نمی‌دهد ربات اول پیام بدهد؛ پس این پیام ممکن است نرسد. مشکلی نیست — فقط Start بزنید.

🎉 **تبریک! ربات شما آماده است.**

---

<a id="fa-9"></a>

### ۹. «بدون دامنه» چطور کار می‌کند؟

تلگرام فقط به آدرس‌های **HTTPS با گواهی معتبر** پیام می‌فرستد. معمولاً برای این کار دامنه می‌خرند، اما نصب‌کننده سه راه رایگان را **به‌ترتیب** امتحان می‌کند تا اولین راهِ موفق را بگیرد:

| اولویت | روش | آدرس نمونه | توضیح |
|:---:|-------|------------|-------|
| ۱ | **گواهی Let's Encrypt برای خود IP** | `https://203.0.113.10` | معتبر و رایگان. عمر هر گواهی حدود **۶ روز** است و **خودکار** هر چند ساعت بررسی و تمدید می‌شود |
| ۲ | هاست‌نیم رایگان **sslip.io** | `https://203-0-113-10.sslip.io` | یک نام رایگان که خودش به IP شما اشاره می‌کند؛ گواهی چندماهه با تمدید خودکار |
| ۳ | هاست‌نیم رایگان **nip.io** | `https://203-0-113-10.nip.io` | مثل مورد قبلی، سرویس جایگزین |

نصب‌کننده بعد از گرفتن هر گواهی، **از خود تلگرام می‌خواهد** به آدرس وصل شود (یک تست واقعی). فقط اگر تلگرام پذیرفت ادامه می‌دهد؛ وگرنه روش بعدی را امتحان می‌کند.

**نکته‌های مهم:**

- 🏦 **درگاه‌های پرداخت ایرانی** (زرین‌پال، آقای پرداخت، ایران‌پی و...) معمولاً آدرس بازگشتِ مربوط به **دامنهٔ ثبت‌شده** شما را می‌خواهند. اگر می‌خواهید از آن‌ها استفاده کنید، **دامنهٔ شخصی** بگیرید و بعد از نصب با `mirzabot reconfigure address` آدرس را عوض کنید. (کارت‌به‌کارت و درگاه‌های کریپتو معمولاً مشکلی ندارند.)
- 🔗 اگر لینک اشتراک (Subscription) یا مینی‌اپ را روی آدرس IP/sslip مشکل‌دار دیدید، همین راهکار (دامنهٔ شخصی) را اجرا کنید.
- 🔁 اگر بعداً دامنه خریدید، نیازی به نصب مجدد نیست:

```bash
mirzabot reconfigure address --domain bot.example.com
```

---

<a id="fa-10"></a>

### ۱۰. مدیریت ربات بعد از نصب

در هر زمان فقط بنویسید:

```bash
mirzabot
```

تا منوی بالا باز شود، یا مستقیم از دستورها استفاده کنید:

| دستور | کاربرد |
|-------|--------|
| `mirzabot status` | **بررسی سلامت**: سرویس‌ها، نسخهٔ PHP، کرون، روزهای باقی‌ماندهٔ SSL، خطاهای وب‌هوک |
| `mirzabot update` | آپدیت به آخرین نسخه (با بکاپ و بازگشت خودکار) |
| `mirzabot backup` | گرفتن بکاپ از دیتابیس و فایل‌ها |
| `mirzabot restore` | بازیابی از بکاپ |
| `mirzabot reconfigure token` | عوض‌کردن توکن ربات |
| `mirzabot reconfigure admin` | عوض‌کردن آیدی ادمین اصلی |
| `mirzabot reconfigure address` | تغییر آدرس (خودکار ⇄ دامنه) |
| `mirzabot ssl` / `mirzabot ssl renew` | وضعیت SSL / تمدید فوری |
| `mirzabot webhook` / `mirzabot webhook fix` | نمایش / تعمیر وب‌هوک تلگرام |
| `mirzabot logs` | دیدن لاگ ربات، آپاچی یا نصب |
| `mirzabot remove` | حذف ربات |
| `mirzabot help` | همهٔ گزینه‌ها |

---

<a id="fa-11"></a>

### ۱۱. آپدیت

```bash
mirzabot update
```

چه اتفاقی می‌افتد؟

1. نسخهٔ نصب‌شده با آخرین نسخه مقایسه می‌شود (اگر جدید نباشد، چیزی تغییر نمی‌کند).
2. **بکاپ کامل** (دیتابیس + فایل‌ها) در `/var/backups/mirzabot/` گرفته می‌شود.
3. نسخهٔ جدید دانلود و کتابخانه‌هایش **قبل از تغییر ربات** آماده می‌شود. اگر این مرحله خراب شود، هیچ چیز تغییر نکرده است.
4. فایل‌های برنامه جایگزین می‌شوند؛ ولی این‌ها **دست‌نخورده** می‌مانند: `config.php`، پوشهٔ `storage`، متن‌های سفارشی (`lang/override`) و ربات‌های نمایندگان (`vpnbot`).
5. جدول‌های دیتابیس به‌روز و وب‌هوک دوباره ثبت می‌شود.
6. اگر در مرحلهٔ ۴ یا ۵ خطایی پیش بیاید، **خودکار به نسخهٔ قبلی برمی‌گردد**.

> برای نصب یک نسخهٔ مشخص: `mirzabot update --tag 0.9` — برای شاخهٔ دیگر: `mirzabot update --branch dev` — و برای نصب مجدد همان نسخه: `mirzabot update --force`
>
> خودِ `mirzabot` هم هر بار با آپدیت ربات، به‌روز می‌شود. برای به‌روزرسانی فقط خود نصب‌کننده: `mirzabot self-update`

---

<a id="fa-12"></a>

### ۱۲. بکاپ و بازیابی

**گرفتن بکاپ:**

```bash
mirzabot backup
```

بکاپ در `/var/backups/mirzabot/manual-تاریخ-ساعت/` ذخیره می‌شود و شامل این‌هاست:

| فایل | محتوا |
|------|-------|
| `database.sql.gz` | تمام اطلاعات دیتابیس (کاربران، سفارش‌ها، تنظیمات...) |
| `app-files.tar.gz` | فایل‌های ربات (شامل `config.php` و ربات‌های نمایندگان) |
| `config.php` | یک کپی جدا از تنظیمات |
| `installer.conf` | تنظیمات نصب‌کننده |

بکاپ را **حتماً از روی سرور بردارید** (روی کامپیوتر خودتان):

```bash
scp -r root@IP-SERVER:/var/backups/mirzabot/manual-20261105-120000 .
```

**بازیابی:**

```bash
mirzabot restore
```

لیست بکاپ‌ها نمایش داده می‌شود؛ شماره را انتخاب کنید. قبل از هر بازیابی، از وضعیت فعلی هم یک **بکاپ ایمنی** گرفته می‌شود تا اگر اشتباه کردید راه برگشت داشته باشید. برای بازیابی از یک فایل مشخص (مثلاً بکاپی که روی کامپیوتر دارید و به سرور فرستاده‌اید):

```bash
mirzabot restore /root/database.sql.gz
```

> 💡 خودِ ربات هم از طریق کرون، بکاپ دوره‌ای برای شما در تلگرام می‌فرستد؛ بکاپ‌گیری `mirzabot` مکمل آن است.

---

<a id="fa-13"></a>

### ۱۳. حذف کامل

```bash
mirzabot remove
```

- برای تأیید باید کلمهٔ **`DELETE`** را تایپ کنید (جلوگیری از اشتباه).
- پیشنهاد می‌دهد **بکاپ نهایی** در `/root/mirzabot-final-backup` بگیرد (پیشنهاد: بله).
- این موارد حذف می‌شوند: وب‌هوک تلگرام، کرون‌جاب‌ها، سایت Apache، گواهی SSL و تایمر تمدید، دیتابیس و کاربرش، فایل‌های ربات.
- بسته‌هایی مثل Apache/PHP/MySQL **پاک نمی‌شوند** (ممکن است سایت‌های دیگری از آن‌ها استفاده کنند). اگر می‌خواهید بسته‌هایی که **خودِ نصب‌کننده** اضافه کرده هم پاک شوند: `mirzabot remove --purge-stack`

گزینه‌ها: `--keep-db` (دیتابیس را نگه دار) · `--no-backup` (بکاپ نهایی نگیر) · `--yes` (سؤال نپرس)

---

<a id="fa-14"></a>

### ۱۴. نصب بدون سؤال (برای حرفه‌ای‌ها)

برای اسکریپت‌نویسی یا نصب روی چند سرور:

```bash
# بدون دامنه
mirzabot install --token 123456789:AAHxxxxxxxx --admin 123456789 --yes

# با دامنهٔ شخصی (رکورد A باید از قبل ساخته شده باشد)
mirzabot install --token 123456789:AAHxxxxxxxx --admin 123456789 --domain bot.example.com --yes

# اگر mirzabot هنوز نصب نیست، همان دستور اصلی را با گزینه اجرا کنید:
bash <(curl -fsSL https://raw.githubusercontent.com/kiarash707/mirzabot.kia/main/easy-install.sh) \
     install --token 123456789:AAHxxxxxxxx --admin 123456789 --yes
```

| گزینه | کاربرد |
|-------|--------|
| `--token` | توکن ربات |
| `--admin` | آیدی عددی ادمین |
| `--domain` | دامنهٔ شخصی (پیش‌فرض: بدون دامنه) |
| `--email` | ایمیل برای هشدار انقضای Let's Encrypt (اختیاری) |
| `--branch` / `--tag` | نصب از یک شاخه / نسخهٔ مشخص |
| `--repo` | مخزن گیت‌هاب دیگر (`owner/name`) |
| `--yes` | هیچ سؤالی نپرس |
| `--force` | نصب مجدد / رد کردن بررسی سیستم‌عامل / آپدیت اجباری |
| `--no-color` | خروجی بدون رنگ |

متغیرهای محیطی: `MIRZA_DB_ROOT_PASS` (فقط اگر رمز root دیتابیس دارید) · `GITHUB_TOKEN` (برای مخزن خصوصی)

---

<a id="fa-15"></a>

### ۱۵. فایل‌ها و مسیرها

| مسیر | محتوا |
|------|-------|
| `/var/www/mirzabot` | فایل‌های ربات و `config.php` |
| `/etc/mirzabot/installer.conf` | تنظیمات نصب (آدرس، دیتابیس و...) — فقط root |
| `/var/backups/mirzabot` | بکاپ‌ها |
| `/var/log/mirzabot-installer.log` | لاگ نصب‌کننده |
| `/var/www/mirzabot/error_log` | خطاهای خود ربات |
| `/var/log/apache2/mirzabot-error.log` | خطاهای Apache |
| `/etc/apache2/sites-available/000-mirzabot*.conf` | تنظیم سایت (توسط نصب‌کننده مدیریت می‌شود؛ دستی ویرایش نکنید) |
| `/etc/letsencrypt/live/mirzabot/` | گواهی SSL |
| `/usr/local/bin/mirzabot` | دستور مدیریت |

---

<a id="fa-16"></a>

### ۱۶. عیب‌یابی

اول از همه این دستور را بزنید؛ معمولاً مشکل را مستقیم نشان می‌دهد:

```bash
mirzabot status
```

| مشکل | علت محتمل | راه‌حل |
|------|-----------|--------|
| `Cannot reach api.telegram.org` | سرور داخل ایران است یا تلگرام فیلتر است | از یک سرور خارج از ایران استفاده کنید |
| `Port 80/443 is already used by 'nginx'` | وب‌سرور دیگری روی سرور هست | `systemctl disable --now nginx` یا یک سرور تمیز بگیرید |
| `Telegram rejected this token` | توکن اشتباه تایپ شده یا در BotFather ابطال (Revoke) شده | توکن را دوباره از BotFather کپی کنید |
| `HTTPS could not be set up` | پورت ۸۰/۴۴۳ بسته است، یا سقف درخواست Let's Encrypt پر شده، یا DNS دامنه درست نیست | پورت‌ها را در فایروال سرویس‌دهنده باز کنید؛ یک ساعت بعد دوباره تلاش کنید؛ یا دامنهٔ شخصی بدهید: `mirzabot install --domain bot.example.com` |
| `PHP 8.5.12+ is not available` | مخزن PHP برای این نسخهٔ سیستم‌عامل در دسترس نیست | از Ubuntu 22.04/24.04 یا Debian 12/13 استفاده کنید |
| ربات جواب نمی‌دهد | وب‌هوک مشکل دارد | `mirzabot webhook fix` سپس `mirzabot status` |
| `Last error: ... SSL ...` در status | گواهی تمدید نشده یا مشکل شبکه | `mirzabot ssl renew` |
| ربات پیام کرون/اعلان نمی‌فرستد | کرون‌جاب ثبت نشده | `mirzabot update --force` (دوباره ثبتش می‌کند) |
| پیام تأیید نصب نرسید | هنوز در ربات Start نزده‌اید | در ربات Start بزنید؛ مشکلی نیست |
| `Database root login failed` | روی سرور از قبل MySQL با رمز root هست | `MIRZA_DB_ROOT_PASS='رمز' mirzabot install ...` |
| نصب وسط راه قطع شد (قطعی اینترنت و...) | — | **همان دستور نصب را دوباره بزنید**؛ مراحل انجام‌شده رد می‌شوند |
| `A Mirza Bot installed by the classic install.sh was found` | قبلاً با `install.sh` قدیمی نصب شده | دو نصب‌کننده را روی یک سرور قاطی نکنید؛ اول نسخهٔ قبلی را حذف کنید یا از سرور تمیز استفاده کنید |

دیدن لاگ‌ها:

```bash
mirzabot logs            # انتخاب از منو
mirzabot logs app        # خطاهای ربات
mirzabot logs apache     # خطاهای وب‌سرور
mirzabot logs install    # لاگ نصب
```

اگر مشکل حل نشد، آخرین ۵۰ خط `/var/log/mirzabot-installer.log` را (**بدون توکن و رمزها**) در [گروه پشتیبانی](https://t.me/mirzapanelgroup) یا بخش [Issues](https://github.com/kiarash707/mirzabot.kia/issues) بفرستید.

---

<a id="fa-17"></a>

### ۱۷. سؤالات پرتکرار

**آیا واقعاً دامنه لازم نیست؟**
خیر. نصب‌کننده گواهی معتبر برای IP یا هاست‌نیم رایگان می‌گیرد. دامنه فقط در حالت‌هایی مثل درگاه‌های ایرانی توصیه می‌شود ([بخش ۹](#fa-9)).

**گواهی IP فقط ۶ روز اعتبار دارد؛ خطر ندارد؟**
نه؛ این طراحی Let's Encrypt است و تمدید **خودکار** است (هر ۶ ساعت بررسی می‌شود). وضعیت را با `mirzabot status` ببینید. اگر Let's Encrypt برای IP شما صادر نکرد، نصب‌کننده خودش به sslip.io (گواهی چندماهه با تمدید خودکار) می‌رود.

**آدرس من با عوض‌شدن IP سرور چه می‌شود؟**
اگر IP سرور عوض شود، آدرس بدون‌دامنه هم باید عوض شود: `mirzabot reconfigure address`. برای آدرس ثابت و حرفه‌ای‌تر، دامنهٔ شخصی بگیرید.

**می‌توانم بعداً دامنه اضافه کنم؟**
بله: `mirzabot reconfigure address --domain bot.example.com`

**با نصب‌کنندهٔ قدیمی (`install.sh`) چه فرقی دارد؟**
`install.sh` دامنه می‌خواهد و حذف آن، Apache و MySQL را کامل پاک می‌کند. نصب‌کنندهٔ آسان بدون دامنه کار می‌کند، هنگام حذف فقط خود ربات را پاک می‌کند (نه کل Apache/MySQL)، و در آپدیت بکاپ و بازگشت خودکار دارد. هر دو را روی **یک سرور** قاطی نکنید.

**phpMyAdmin نصب می‌شود؟**
نه، عمداً (سطح حملهٔ اضافه است). برای دسترسی به دیتابیس: `mysql` را به‌عنوان root اجرا کنید (`mysql -u root`).

**چند ربات روی یک سرور می‌شود؟**
این نصب‌کننده یک نصب برای هر سرور مدیریت می‌کند. «ربات‌ساز/نماینده‌ها» داخل خود ربات (منوی نمایندگی) انجام می‌شود و در بکاپ و آپدیت حفظ می‌شود.

**حتماً باید Ubuntu باشد؟**
Ubuntu 22.04/24.04 تست‌شده‌ترین است؛ Debian 12/13 هم پشتیبانی می‌شود. سایر سیستم‌عامل‌ها فقط با `--force` و با مسئولیت خودتان.

---

<a id="fa-18"></a>

### ۱۸. نکات امنیتی

- 🔑 **توکن ربات** را فقط در BotFather و روی همین سرور نگه دارید. اگر لو رفت: BotFather ← `/revoke` و بعد `mirzabot reconfigure token`
- 🔒 دسترسی root را با **رمز قوی** یا **کلید SSH** حفظ کنید. بعد از نصب پیشنهاد می‌شود ورود با رمز غیرفعال و `fail2ban` نصب شود.
- 🧱 فایروال سرور (`ufw`) را فقط روی پورت‌های `22, 80, 443` باز بگذارید. نصب‌کننده اگر ufw فعال باشد ۸۰ و ۴۴۳ را خودش باز می‌کند و **هرگز** خودش ufw را فعال نمی‌کند (تا از سرور بیرون نیفتید).
- 💾 هفتگی بکاپ بگیرید و **خارج از سرور** نگه دارید (`mirzabot backup`).
- 🗄️ دیتابیس فقط روی `localhost` در دسترس است و کاربر مخصوص خودش را دارد؛ رمز تصادفی ۳۲ کاراکتری است.
- ♻️ سیستم را به‌روز نگه دارید: `apt update && apt upgrade -y` و بعد `mirzabot update`.

</div>

---

## 💎 Free vs. Pro

| | Free 🆓 | Pro 💎 |
|---|:---:|:---:|
| Automated VPN sales & config creation | ✅ | ✅ |
| Trial accounts, wallet & service management | ✅ | ✅ |
| All supported panels & payment gateways | ✅ | ✅ |
| Advanced customization & analytics | — | ✅ |
| Enhanced management & extra modules | — | ✅ |

📌 **Pro purchase guide:** [View on Telegram »](https://t.me/mirzaperimium/4)

---

## 🌍 Languages

Mirza Bot ships with full translations for:

🇬🇧 English · 🇮🇷 Persian (فارسی) · 🇷🇺 Russian (Русский) · 🇨🇳 Chinese (中文)

---

## 💵 Support the Project

If **Mirza Bot** helps your business, please consider supporting its development with a crypto donation:

<a href="https://nowpayments.io/donation/mahdi">
  <img src="https://img.shields.io/badge/Donate-NowPayments-1A1A2E?style=for-the-badge&logo=bitcoin&logoColor=white" alt="Donate"/>
</a>

Your support keeps the updates and improvements coming. Thank you! 🙌

---

## 👥 Contributors

Thanks to everyone who has contributed to making Mirza Bot better:

<a href="https://github.com/mahdiMGF2/mirzabot/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=mahdiMGF2/mirzabot" alt="Contributors"/>
</a>

---

<div align="center">

**Made with ❤️ by the Mirza Panel community**

📖 [Documentation](https://mirzabot.com/docs/) · 💬 [Channel](https://t.me/mirzapanel) · 👥 [Group](https://t.me/mirzapanelgroup) · ⭐ [Star on GitHub](https://github.com/mahdiMGF2/mirzabot)

</div>
