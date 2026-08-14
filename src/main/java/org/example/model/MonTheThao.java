package org.example.model;

import jakarta.persistence.*;

@Entity
@Table(name = "MonTheThao")
public class MonTheThao {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "MonTheThaoID")
    private int MonTheThaoID;

    @Column(name = "TenMon")
    private String TenMon;

    public MonTheThao() {
    }

    public MonTheThao(int monTheThaoID, String tenMon) {
        MonTheThaoID = monTheThaoID;
        TenMon = tenMon;
    }

    public int getMonTheThaoID() {
        return MonTheThaoID;
    }

    public void setMonTheThaoID(int monTheThaoID) {
        MonTheThaoID = monTheThaoID;
    }

    public String getTenMon() {
        return TenMon;
    }

    public void setTenMon(String tenMon) {
        TenMon = tenMon;
    }

    @Override
    public String toString() {
        return "MonTheThao{" +
                "MonTheThaoID=" + MonTheThaoID +
                ", TenMon='" + TenMon + '\'' +
                '}';
    }
}
