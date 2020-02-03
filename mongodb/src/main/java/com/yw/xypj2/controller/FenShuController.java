package com.yw.xypj2.controller;

import com.yw.xypj2.dao.FenShuRepository;
import com.yw.xypj2.domain.PinjiazhibiaoDafen;
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

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

@RestController
@RequestMapping("/fenShu")
@Slf4j
@CrossOrigin
public class FenShuController {
    // private final Logger logger = Logger.getLogger(getClass());

    @Qualifier("eurekaRegistration")
    @Autowired
    private Registration registration; // 服务注册

    @Autowired
    private DiscoveryClient client;// 服务发现客户端

    @Autowired
    FenShuRepository fenShuRep;

    /**
     * RESTful 查询返回所欲的评价指标打分
     * @return
     */
    @GetMapping
    public ResponseEntity<List<PinjiazhibiaoDafen>> getAll() {
        List<PinjiazhibiaoDafen> ls = fenShuRep.findAll();


        //根据单位名称排序
        Collections.sort(ls, new Comparator<PinjiazhibiaoDafen>() {
            public int compare(PinjiazhibiaoDafen arg0, PinjiazhibiaoDafen arg1) {
                return arg0.getDanWei().getName().compareTo(arg1.getDanWei().getName());
            }
        });

        log.info("== " + registration.getInstanceId());
       /* ls.forEach(p -> {
            log.info("== " + p.getDanWei().getName());
        });
*/
        //log.info("==： " + ls.get(0).getDanWei().getName());
        return ResponseEntity.ok(ls);
    }

}
