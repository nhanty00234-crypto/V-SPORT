package org.example.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

public class EmailUtil {
    private static final String HOST = "smtp.gmail.com";
    private static final String PORT = "465"; 
    private static final String USERNAME = "nhanntty00234@gmail.com"; 
    private static final String PASSWORD = "ghtnukwuzwbaqarp";

    public static void sendEmail(String toAddress, String subject, String body) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.host", HOST);
        props.put("mail.smtp.port", PORT);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.ssl.enable", "true"); 
        props.put("mail.smtp.socketFactory.port", PORT);
        props.put("mail.smtp.socketFactory.class", "jakarta.net.ssl.SSLSocketFactory");
        props.put("mail.smtp.connectiontimeout", "5000");
        props.put("mail.smtp.timeout", "5000");

        // Force Jakarta Activation to use Eclipse Angus content handlers to avoid conflicts (configured via reflection to avoid compile issues)
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
            System.err.println("Failed to configure MailcapCommandMap via reflection: " + e.getMessage());
        }

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });
        
        session.setDebug(true);

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(USERNAME));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toAddress));
        message.setSubject(subject);
        message.setText(body);

        Transport.send(message);
    }
}


