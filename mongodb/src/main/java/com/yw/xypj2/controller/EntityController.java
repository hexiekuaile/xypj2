package com.yw.xypj2.controller;

import com.yw.xypj2.dao.EntityRepository;
import com.yw.xypj2.domain.Entity;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.cloud.client.serviceregistry.Registration;
import org.springframework.data.mongodb.core.MongoOperations;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/entity")
@Slf4j
@CrossOrigin
//跨域
public class EntityController {
    // private final Logger logger = Logger.getLogger(getClass());

    @Qualifier("eurekaRegistration")
    @Autowired
    private Registration registration; // 服务注册

    @Autowired
    private DiscoveryClient client;// 服务发现客户端

    @Autowired
    EntityRepository entityRep;

    @Autowired
    MongoOperations mongoOperation;

    /**
     * Restful 查询返回所有数据
     *
     * @return
     */
    @GetMapping("/")
    public ResponseEntity<List<Entity>> getAll() {
        List<Entity> ls = entityRep.findAll();
        //log.info("== " + registration.getInstanceId());
        //log.info("==基础信息： " + ls.get(0).getMap());
        return ResponseEntity.ok(ls);
    }

    /**
     * @param attribute
     * @param value
     * @return
     */
    @GetMapping("/map/{attribute}/{value}")
    public ResponseEntity<List<Entity>> findByMap(@PathVariable("attribute") String attribute, @PathVariable("value") String value) {
        //log.info("== " +attribute+" "+ value);
        List<Entity> list = entityRep.findByMap(attribute, value);
        //log.info("== " + list.size());
        return ResponseEntity.ok(list);
    }

    /**
     * 插入
     *
     * @param e
     * @return
     */
    @PostMapping("/")
    public ResponseEntity<String> post(@RequestBody Entity e) {
        // log.info("========== " + m.getName() + m.getType() + m.getMap().toString());
        e = entityRep.insert(e);

        // log.info("增加基础信息：" + "名称:{},类型:{}", m.getName(), m.getType());
        //表示有返回数据，并且响应状态码是 201
        return ResponseEntity.status(HttpStatus.CREATED).body(e.getId());
    }

    /**
     * 更新
     *
     * @param e
     * @return
     */
    @PutMapping("/")
    public ResponseEntity<Void> put(@RequestBody Entity e) {
      /*  Entity en = entityRep.findById(e.getId()).get();
        e.getMap().forEach((k, v) -> {
            en.getMap().put(k, v);
        });
        entityRep.save(en);*/

        Query query = new Query();
        query.addCriteria(Criteria.where("id").is(e.getId()));
        Update update = new Update();
        e.getMap().forEach((k, v) -> {
            update.set("map." + k, v);
        });
        mongoOperation.upsert(query, update, Entity.class);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable("id") String id) {
        entityRep.deleteById(id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }
}
