
/*
 * Copyright (c) 2017，版权归yw所有。
 * 项目名称：xypj2
 * 文件名称：  Shiti.java
 * 日期： 17-10-12 上午11:09
 * 作者：闫伟
 */

package com.yw.xypj2.domain;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.ToString;
import org.springframework.data.annotation.Id;

import java.util.HashMap;
import java.util.Map;

@AllArgsConstructor
@Data
@ToString
public class Entity {
    @Id
    private String id;
    private Map<String, Object> map = new HashMap<String, Object>();
}
