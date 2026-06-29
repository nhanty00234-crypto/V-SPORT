package org.example.dao;

import org.example.model.CoSo;
import java.util.List;

public interface CoSoDAO {
    List<CoSo> getAllCoSo();
    CoSo getCoSoById(int id);
    boolean addCoSo(CoSo coSo);
    boolean updateCoSo(CoSo coSo);
    boolean deleteCoSo(int id);
}
