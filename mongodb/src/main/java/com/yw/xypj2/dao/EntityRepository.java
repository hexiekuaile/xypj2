package com.yw.xypj2.dao;

import com.yw.xypj2.domain.Entity;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface EntityRepository extends MongoRepository<Entity, String> {
    // @Query(value = "{'map.type' : ?0}")
    // @Query("{'map.type' : ?0}")
    @Query("{?0 : ?1}")
    List<Entity> findByMap(String prop, String type);


}
