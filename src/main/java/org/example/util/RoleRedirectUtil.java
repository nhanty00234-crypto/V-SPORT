package org.example.util;

/**
 * Nguồn sự thật duy nhất cho mapping roleId → home route.
 * Khớp bảng VaiTro: 1=Admin, 2=Manager, 3=Customer, 4=Lễ tân, 5=Bảo vệ.
 */
public class RoleRedirectUtil {

    public static final int ROLE_ADMIN    = 1;
    public static final int ROLE_MANAGER  = 2;
    public static final int ROLE_CUSTOMER = 3;
    public static final int ROLE_LETÂN    = 4;
    public static final int ROLE_BAOVE    = 5;

    public static String getHomePathByRoleId(Integer roleId) {
        if (roleId == null) return "/index.jsp";
        switch (roleId) {
            case ROLE_ADMIN:    return "/admin/tong-quan";
            case ROLE_MANAGER:  return "/manager/dashboard";
            case ROLE_LETÂN:
            case ROLE_BAOVE:    return "/staff/dashboard";
            case ROLE_CUSTOMER:
            default:            return "/index.jsp";
        }
    }

    public static boolean isStaff(int roleId) {
        return roleId == ROLE_LETÂN || roleId == ROLE_BAOVE;
    }
}
