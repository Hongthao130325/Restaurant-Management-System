package util;

public class PasswordUtils {
    
    // Không mã hóa, trả về plain text
    public static String hashPassword(String plainPassword) {
        return plainPassword;
    }
    
    // So sánh trực tiếp
    public static boolean checkPassword(String plainPassword, String storedPassword) {
        return plainPassword.equals(storedPassword);
    }
}
