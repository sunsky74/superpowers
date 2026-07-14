# Fork Merge Notes

> 本文档记录本 fork 相对 `obra/superpowers` 上游的所有改动点。每次 `git fetch upstream && git merge upstream/main` 前,先对照本文档检查冲突预案。

**Fork 基线:** v6.0.3(commit `896224c`)
**最后更新:** 2026-06-29

---

## 改动总览

| # | 类型 | 文件 | 改动性质 |
|---|---|---|---|
| 1 | 新建 skill | `skills/three-pillars/SKILL.md` | 承载三要素适用范围判定 + 项目类型分支 + 提问框架 + design 输出 + Red Flags + Self-Review |
| 2 | 新建 skill | `skills/acceptance-driven-plan/SKILL.md` | 承载验收驱动 plan 结构(最终验收清单 header + Level 字段 + L1-L3 标准 + handoff 三选一 + Self-Review) |
| 3 | 新建 skill | `skills/ltdd/SKILL.md` | LTDD 双层验收循环执行 skill |
| 4 | 修改 skill | `skills/brainstorming/SKILL.md` | 加入 5 处 FORK TRIGGER,调用 three-pillars |
| 5 | 修改 skill | `skills/writing-plans/SKILL.md` | 加入 5 处 FORK TRIGGER,调用 acceptance-driven-plan |
| 6 | 新建文档 | `docs/superpowers/specs/2026-06-25-brainstorm-writing-plan-ltdd-integration-design.md` | 本 fork 的设计 spec |
| 7 | 新建文档 | `docs/superpowers/plans/2026-06-25-brainstorm-writing-plan-ltdd-integration.md` | 本 fork 的实施 plan |
| 8 | 本文档 | `docs/superpowers/fork-merge-notes.md` | fork 改动记录(供上游 sync) |

---

## 上游 sync 冲突预案

### 极低冲突风险(< 5%)

| 文件 | 改动形式 | 冲突原因 | 应对 |
|---|---|---|---|
| `skills/three-pillars/SKILL.md` | 全新文件 | 上游不存在此文件 | 永不冲突 |
| `skills/acceptance-driven-plan/SKILL.md` | 全新文件 | 同上 | 永不冲突 |
| `skills/ltdd/SKILL.md` | 全新文件 | 同上 | 永不冲突 |
| `docs/superpowers/specs/...` | 全新文件 | 同上 | 永不冲突 |
| `docs/superpowers/plans/...` | 全新文件 | 同上 | 永不冲突 |

### 低冲突风险(< 15%)

| 文件 | 改动形式 | 潜在冲突点 | 应对 |
|---|---|---|---|
| `skills/brainstorming/SKILL.md` | 5 处 FORK TRIGGER(每处 1-3 行) | 上游若改 Anti-Pattern 段、Checklist 编号、Process 段、Self-Review 段、Red Flags 段 — 会与我们的 trigger 标记相邻 | trigger 都是 `> **FORK TRIGGER:**` 块引用形式,git 三方合并通常能自动处理。冲突时手工保留 trigger 块即可 |
| `skills/writing-plans/SKILL.md` | 5 处 FORK TRIGGER + 2 处 `[//]: # (FORK ...)` 注释 | 上游若改 Plan Document Header 模板、Task Structure 模板、Self-Review、Execution Handoff | 同上 |

### 不冲突

| 项 | 原因 |
|---|---|
| YAML front-matter | 已恢复为上游原版(name/description 未改) |
| HARD-GATE / Anti-Pattern / Visual Companion | 未触动 |
| Process Flow graph | 未触动 |
| Key Principles | 未触动 |

---

## 上游 sync 操作步骤

```bash
# 1. 拉取上游
git fetch upstream

# 2. 在 dev 分支或专门的 sync 分支上 merge
git checkout -b sync-upstream-YYYY-MM-DD
git merge upstream/main

# 3. 若 brainstorming/SKILL.md 冲突
#    打开文件,搜索 "FORK TRIGGER"
#    确认每处 trigger 仍在(共 5 处)
#    上游的新内容保留,trigger 块也保留
#    手工 reconcile 后 git add

# 4. 若 writing-plans/SKILL.md 冲突
#    同上,搜索 "FORK TRIGGER"(5 处)+ "[//]: # (FORK"  (2 处)

# 5. 跑回归(若有 tests/run-*.sh)
ls tests/run-*.sh 2>/dev/null && bash tests/run-*.sh

# 6. 手工 dogfood:跑一个简单 brainstorming,确认 FORK TRIGGER 正常触发 three-pillars

# 7. 提交 merge
git commit
```

---

## FORK TRIGGER 在 brainstorming/SKILL.md 的位置

| # | 位置 | 内容 |
|---|---|---|
| 1 | Checklist 第 3 项之后(替代原 §3a) | 触发 three-pillars 做适用范围判定 + 项目类型判定 + 四角度提问 + design 输出 |
| 2 | Process 段 "Understanding the idea" 之后 | 指向 three-pillars §4 提问框架 + §5 输出模板 |
| 3 | Process 段 "Presenting the design" 之后 | 指向 three-pillars §5 design 输出模板 |
| 4 | Self-Review 第 4 项之后 | 指向 three-pillars §6 Self-Review 检查项 #5-#11 |
| 5 | Red Flags 段开头 | 指向 three-pillars §7 Red Flags |

## FORK TRIGGER 在 writing-plans/SKILL.md 的位置

| # | 位置 | 内容 |
|---|---|---|
| 1 | Plan Document Header 段开头 | 指向 acceptance-driven-plan §1(最终验收清单 header) |
| 2 | Plan Document Header 模板内 `[//]: # (FORK ...)` 注释 | 占位标记,提示插入最终验收清单段 |
| 3 | Task Structure 段开头 | 指向 acceptance-driven-plan §2(Level 字段) |
| 4 | Task Structure 模板内 `[//]: # (FORK ...)` 注释 | 占位标记,提示插入 Level 字段 |
| 5 | Task Structure 段末尾 | 指向 acceptance-driven-plan §3(L1-L3 判定标准) |
| 6 | Self-Review 第 3 项之后 | 指向 acceptance-driven-plan §5(Self-Review #4-#8) |
| 7 | Execution Handoff 段开头 | 指向 acceptance-driven-plan §4(三选一 handoff) |

---

## 验证 fork 触发链完整的 grep 命令

每次 merge 后跑一次,确认 trigger 没丢:

```bash
echo "=== brainstorming FORK TRIGGER 应 ≥ 5 ==="
grep -c "FORK TRIGGER" skills/brainstorming/SKILL.md

echo "=== writing-plans FORK TRIGGER 应 ≥ 5 ==="
grep -c "FORK TRIGGER" skills/writing-plans/SKILL.md

echo "=== brainstorming 调用 three-pillars 应 ≥ 5 ==="
grep -c "three-pillars" skills/brainstorming/SKILL.md

echo "=== writing-plans 调用 acceptance-driven-plan 应 ≥ 5 ==="
grep -c "acceptance-driven-plan" skills/writing-plans/SKILL.md

echo "=== 新 skill 文件应都存在 ==="
test -f skills/three-pillars/SKILL.md && echo "three-pillars OK"
test -f skills/acceptance-driven-plan/SKILL.md && echo "acceptance-driven-plan OK"
test -f skills/ltdd/SKILL.md && echo "ltdd OK"

echo "=== writing-plans handoff 三选一应都在 ==="
grep -cE "ltdd|subagent-driven-development|executing-plans" skills/writing-plans/SKILL.md
```

预期:每条都通过,数字 ≥ 阈值。若有任何一条失败,说明 merge 时丢了 trigger,需手工补回。
