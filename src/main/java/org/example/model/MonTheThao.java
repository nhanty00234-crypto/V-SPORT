package org.example.model;

import jakarta.persistence.*;

@Entity
@Table(name = "sports")
public class MonTheThao {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "sport_id")
    private int MonTheThaoID;

    @Column(name = "sport_name")
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
