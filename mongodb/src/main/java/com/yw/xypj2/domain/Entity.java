
/*
 * Copyright (c) 2017，版权归闫伟所有。
 * 项目名称：xypj
 * 文件名称：  Shiti.java
 * 日期： 17-10-12 上午11:09
 * 作者：闫伟
 */

package com.yw.xypj2.domain;

import org.springframework.data.annotation.Id;

import java.util.HashMap;
import java.util.Map;

public class Shiti {
    @Id
    private String id;
    private Map<String, Object> map = new HashMap<String, Object>();

    public Shiti() {
    }

    public Shiti(String id, Map<String, Object> map) {
        this.id = id;
        this.map = map;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Map<String, Object> getMap() {
        return map;
    }

    public void setMap(Map<String, Object> map) {
        this.map = map;
    }

    public void put(String key, Object value) {
        this.map.put(key, value);
    }

    public Object get(String key) {
        return this.map.get(key);
    }

}
