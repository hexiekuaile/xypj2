package com.yw.xypj2.dao;

import com.yw.xypj2.domain.Info;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InfoRepository extends MongoRepository<Info, String> {
    Info findByName(String name);
    List<Info> findByType(String type);
    //@Query("{'age': ?0}")
    // List<Canpingqiye> withQueryFindByAge(Integer age);
}
