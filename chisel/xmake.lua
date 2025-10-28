local PRJ = "demo"
local BUILD_DIR = "./build"

target("chisel")
    set_kind("phony")
    
    -- 使用 Lua 字符串拼接变量，并使用 os.exec 的 pwd 参数
    on_build(function (target)
        
        -- 1. 构建完整的命令字符串，使用 Lua 变量 PRJ 和 xmake 内置变量 $(buildir)
        local cmd = string.format("./mill -i %s.runMain Elaborate --target-dir %s --full-stacktrace", PRJ, BUILD_DIR)
        
        os.cd("chisel")
        os.exec(cmd)
    end)

target("chisel_demo")
    add_deps("chisel")  -- 先构建 chisel，生成 .sv 文件
    add_rules("verilator.binary")
    set_toolchains("@verilator")
    add_files("csrc/*.cpp")
    add_files("build/*.sv")
    add_values("verilator.flags", "--trace", "--timing")

    add_options("WAVE_FILE_NAME", "WAVE_MAX_CYCLES", "CNTER_WIDTH")
    add_includedirs("$(builddir)")
    
    add_configfiles("csrc/config_chisel.h.in")
    after_run(function (target)
        os.exec("gtkwave %s/wave.vcd", target:targetdir())
    end)

    add_packages("fmt")