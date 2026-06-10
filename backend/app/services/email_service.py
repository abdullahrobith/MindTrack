import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.core.config import settings

def send_email(to_email: str, subject: str, html_content: str):
    if not settings.SMTP_EMAIL or not settings.SMTP_PASSWORD:
        print(f"Warning: SMTP not configured. Would have sent email to {to_email} with subject: {subject}")
        return

    msg = MIMEMultipart("alternative")
    msg["Subject"] = subject
    msg["From"] = settings.SMTP_EMAIL
    msg["To"] = to_email

    part1 = MIMEText(html_content, "html")
    msg.attach(part1)

    try:
        server = smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT)
        server.starttls()
        server.login(settings.SMTP_EMAIL, settings.SMTP_PASSWORD)
        server.sendmail(settings.SMTP_EMAIL, to_email, msg.as_string())
        server.quit()
    except Exception as e:
        print(f"Failed to send email to {to_email}: {e}")

def send_verification_email(to_email: str, token: str):
    link = f"{settings.APP_URL}/auth/verify-email?token={token}"
    html = f"""
    <html>
      <body>
        <h2>Verifikasi Email MindTrack</h2>
        <p>Silakan klik link di bawah ini untuk memverifikasi akun Anda:</p>
        <a href="{link}" style="padding: 10px 20px; background-color: #007BFF; color: white; text-decoration: none; border-radius: 5px;">Verifikasi Email</a>
        <br><br>
        <p>Atau copy link berikut ke browser Anda: <br> {link}</p>
      </body>
    </html>
    """
    send_email(to_email, "Verifikasi Email Akun Anda", html)

def send_reset_password_email(to_email: str, token: str):
    link = f"{settings.APP_URL}/auth/reset-password?token={token}"
    html = f"""
    <html>
      <body>
        <h2>Reset Password MindTrack</h2>
        <p>Kami menerima permintaan untuk mereset password Anda. Klik link di bawah ini untuk membuat password baru:</p>
        <a href="{link}" style="padding: 10px 20px; background-color: #28A745; color: white; text-decoration: none; border-radius: 5px;">Reset Password</a>
        <br><br>
        <p>Abaikan email ini jika Anda tidak meminta reset password.</p>
      </body>
    </html>
    """
    send_email(to_email, "Reset Password Akun Anda", html)

def send_password_changed_email(to_email: str):
    html = """
    <html>
      <body>
        <h2>Password Berhasil Diubah</h2>
        <p>Password untuk akun MindTrack Anda telah berhasil diubah.</p>
        <p>Jika Anda merasa tidak melakukan perubahan ini, segera hubungi admin kami.</p>
      </body>
    </html>
    """
    send_email(to_email, "Notifikasi Perubahan Password", html)
