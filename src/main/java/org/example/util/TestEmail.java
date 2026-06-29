package org.example.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

public class TestEmail {
    
    private static void trySend(String username, String password) {
        System.out.println("\n-------------------------------------------");
        System.out.println("Testing Username: " + username);
        System.out.println("Testing Password: " + password);
        
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "465");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.ssl.enable", "true"); 
        props.put("mail.smtp.socketFactory.port", "465");
        props.put("mail.smtp.socketFactory.class", "jakarta.net.ssl.SSLSocketFactory");
        props.put("mail.smtp.connectiontimeout", "5000");
        props.put("mail.smtp.timeout", "5000");

        try {
            Class<?> commandMapClass = Class.forName("jakarta.activation.CommandMap");
            Class<?> mailcapCommandMapClass = Class.forName("jakarta.activation.MailcapCommandMap");
            
            java.lang.reflect.Method getDefaultMethod = commandMapClass.getMethod("getDefaultCommandMap");
            java.lang.reflect.Method setDefaultMethod = commandMapClass.getMethod("setDefaultCommandMap", commandMapClass);
            java.lang.reflect.Method addMailcapMethod = mailcapCommandMapClass.getMethod("addMailcap", String.class);
            
            Object mc = getDefaultMethod.invoke(null);
            if (mailcapCommandMapClass.isInstance(mc)) {
                addMailcapMethod.invoke(mc, "text/html;; x-java-content-handler=org.eclipse.angus.mail.handlers.text_html");
                addMailcapMethod.invoke(mc, "text/plain;; x-java-content-handler=org.eclipse.angus.mail.handlers.text_plain");
                addMailcapMethod.invoke(mc, "text/xml;; x-java-content-handler=org.eclipse.angus.mail.handlers.text_xml");
                addMailcapMethod.invoke(mc, "multipart/*;; x-java-content-handler=org.eclipse.angus.mail.handlers.multipart_mixed");
                addMailcapMethod.invoke(mc, "message/rfc822;; x-java-content-handler=org.eclipse.angus.mail.handlers.message_rfc822");
                setDefaultMethod.invoke(null, mc);
            }
        } catch (Exception e) {
            System.err.println("Reflection failed: " + e.getMessage());
        }

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });
        
        session.setDebug(false);

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(username));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse("nhanty00234@gmail.com"));
            message.setSubject("V-Sport OTP Success Test");
            message.setText("This is a success verification email from the V-Sport system.");
            Transport.send(message);
            System.out.println("SUCCESS! Email sent using " + username);
        } catch (Exception e) {
            System.out.println("FAILED for " + username + ": " + e.getMessage());
        }
    }

    public static void main(String[] args) {
        System.out.println("Starting Email Diagnostic Test with new App Password...");
        trySend("nhanntty00234@gmail.com", "ghtnukwuzwbaqarp");
        trySend("nhanty00234@gmail.com", "ghtnukwuzwbaqarp");
    }
}
