package com.yw.xypj2.dao;

import com.yw.xypj2.domain.PinjiazhibiaoDafen;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FenShuRepository extends MongoRepository<PinjiazhibiaoDafen, String> {
    //Canpingqiye findByName(String name);

    //@Query("{'age': ?0}")
    // List<Canpingqiye> withQueryFindByAge(Integer age);
}
