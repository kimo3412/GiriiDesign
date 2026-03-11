package com.designstudio.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.designstudio.common.result.R;
import com.designstudio.system.domain.SysMenu;
import com.designstudio.system.mapper.SysMenuMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * 菜单管理
 */
@RestController
@RequestMapping("/api/v1/admin/menu-list")
@RequiredArgsConstructor
@Tag(name = "菜单管理")
public class SysMenuController {

    private final SysMenuMapper menuMapper;

    @GetMapping
    @Operation(summary = "获取所有菜单树")
    public R<List<SysMenuTree>> list() {
        List<SysMenu> all = menuMapper.selectList(new LambdaQueryWrapper<SysMenu>().orderByAsc(SysMenu::getSortOrder));
        return R.ok(buildTree(all, 0L));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取菜单详情")
    public R<SysMenu> get(@PathVariable Long id) {
        return R.ok(menuMapper.selectById(id));
    }

    @PostMapping
    @Operation(summary = "新增菜单")
    public R<Void> add(@RequestBody SysMenu menu) {
        if (menu.getParentId() == null) {
            menu.setParentId(0L);
        }
        menuMapper.insert(menu);
        return R.ok();
    }

    @PutMapping("/{id}")
    @Operation(summary = "修改菜单")
    public R<Void> update(@PathVariable Long id, @RequestBody SysMenu dto) {
        SysMenu menu = menuMapper.selectById(id);
        if (menu == null) return R.fail("菜单不存在");

        menu.setParentId(dto.getParentId());
        menu.setMenuName(dto.getMenuName());
        menu.setMenuType(dto.getMenuType());
        menu.setPath(dto.getPath());
        menu.setComponent(dto.getComponent());
        menu.setPerms(dto.getPerms());
        menu.setIcon(dto.getIcon());
        menu.setSortOrder(dto.getSortOrder());
        menu.setVisible(dto.getVisible());

        menuMapper.updateById(menu);
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除菜单")
    public R<Void> delete(@PathVariable Long id) {
        // 检查是否有子节点
        Long count = menuMapper.selectCount(new LambdaQueryWrapper<SysMenu>().eq(SysMenu::getParentId, id));
        if (count > 0) {
            return R.fail("存在子菜单，不允许删除");
        }
        menuMapper.deleteById(id);
        return R.ok();
    }

    private List<SysMenuTree> buildTree(List<SysMenu> all, Long parentId) {
        return all.stream()
                .filter(m -> Objects.equals(m.getParentId(), parentId))
                .map(m -> {
                    SysMenuTree node = new SysMenuTree();
                    node.setMenuId(m.getMenuId());
                    node.setParentId(m.getParentId());
                    node.setMenuName(m.getMenuName());
                    node.setMenuType(m.getMenuType());
                    node.setPath(m.getPath());
                    node.setComponent(m.getComponent());
                    node.setPerms(m.getPerms());
                    node.setIcon(m.getIcon());
                    node.setSortOrder(m.getSortOrder());
                    node.setVisible(m.getVisible());
                    node.setChildren(buildTree(all, m.getMenuId()));
                    return node;
                })
                .collect(Collectors.toList());
    }

    public static class SysMenuTree extends SysMenu {
        private List<SysMenuTree> children;

        public List<SysMenuTree> getChildren() {
            return children;
        }

        public void setChildren(List<SysMenuTree> children) {
            this.children = children;
        }
    }
}
