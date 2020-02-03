package com.yw.xypj2.controller;

import com.yw.xypj2.dao.PinjiazhibiaoRepository;
import com.yw.xypj2.domain.Pinjiazhibiao;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.cloud.client.serviceregistry.Registration;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/pjzb")
@Slf4j
@CrossOrigin
public class PinjiazhibiaoController {
    // private final Logger logger = Logger.getLogger(getClass());

    @Qualifier("eurekaRegistration")
    @Autowired
    private Registration registration; // 服务注册

    @Autowired
    private DiscoveryClient client;// 服务发现客户端

    @Autowired
    PinjiazhibiaoRepository pjzbRep;

    /**
     * RESTful 查询分行所有的评价指标
     * @return
     */

    @GetMapping
    public ResponseEntity<List<Pinjiazhibiao>> getAll() {
        List<Pinjiazhibiao> ls = pjzbRep.findAll();

        log.info("== " + registration.getInstanceId());
        //log.info("==指标数量： " + ls.get(0).getName());
        return ResponseEntity.ok(ls);
    }

}
