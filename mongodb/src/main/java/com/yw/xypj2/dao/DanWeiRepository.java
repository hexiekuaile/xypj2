package com.yw.xypj2.dao;

import com.yw.xypj2.domain.DanWei;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DanWeiRepository extends MongoRepository<DanWei, String> {
    //Canpingqiye findByName(String name);

    //@Query("{'age': ?0}")
    // List<Canpingqiye> withQueryFindByAge(Integer age);
}
