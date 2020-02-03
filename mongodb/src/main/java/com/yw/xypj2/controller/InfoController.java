package com.yw.xypj2.controller;

import com.yw.xypj2.dao.InfoRepository;
import com.yw.xypj2.domain.Info;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.cloud.client.serviceregistry.Registration;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/metaInfo")
@Slf4j
@CrossOrigin
//跨域
public class InfoController {
    // private final Logger logger = Logger.getLogger(getClass());

    @Qualifier("eurekaRegistration")
    @Autowired
    private Registration registration; // 服务注册

    @Autowired
    private DiscoveryClient client;// 服务发现客户端

    @Autowired
    InfoRepository metaInfoRep;

    /**
     * Restful 查询返回所有数据
     *
     * @return
     */
    @GetMapping
    public ResponseEntity<List<Info>> get() {
        List<Info> ls = metaInfoRep.findAll();

        //log.info("== " + registration.getInstanceId());
        //log.info("==基础信息： " + ls.get(0).getMap());
        return ResponseEntity.ok(ls);
    }

    /**
     * Restful 查询返回特定名称的基础信息
     *
     * @return
     */
    @GetMapping("/name/{name}")
    public ResponseEntity<Info> get(@PathVariable("name") String name) {
        // log.info("== " + name);
        Info mi = metaInfoRep.findByName(name);
        //log.info("==基础信息： " + ls.get(0).getMap());
        return ResponseEntity.ok(mi);
    }

    /**
     * @param type 查询特定类型的metainfo基础信息
     * @return
     */
    @GetMapping("/type/{type}")
    public ResponseEntity<List<Info>> findByType(@PathVariable("type") String type) {
       // log.info("== " + type);
        List<Info> mi = metaInfoRep.findByType(type);
        //log.info("== " + mi.size());
        return ResponseEntity.ok(mi);
    }

    /**
     * RESTful 添加基础信息
     *
     * @param m
     * @return
     */
    @PostMapping
    public ResponseEntity<Info> post(@RequestBody Info m) {
        // log.info("========== " + m.getName() + m.getType() + m.getMap().toString());
        metaInfoRep.save(m);

        // log.info("增加基础信息：" + "名称:{},类型:{}", m.getName(), m.getType());
        //表示有返回数据，并且响应状态码是 201
        return ResponseEntity.status(HttpStatus.CREATED).body(m);
    }


}
