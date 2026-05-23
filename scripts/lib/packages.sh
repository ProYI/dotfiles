#!/bin/bash
# Package/module configuration parser.

dotfiles_packages_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$dotfiles_packages_lib_dir/common.sh"

declare -gA PACKAGES_BY_CATEGORY=()
declare -gA MODULES_BY_CATEGORY=()
declare -ga ALL_CATEGORIES=()
declare -ga SELECTED_PACKAGES=()
declare -ga SELECTED_MODULES=()

dotfiles_array_contains() {
    local needle="$1"
    shift

    local item
    for item in "$@"; do
        [ "$item" = "$needle" ] && return 0
    done

    return 1
}

dotfiles_parse_package_conf() {
    local conf_file="${1:-$DOTFILES_DIR/config/packages.conf}"
    if [ ! -f "$conf_file" ]; then
        log_error "配置文件不存在: $conf_file"
        return 1
    fi

    PACKAGES_BY_CATEGORY=()
    MODULES_BY_CATEGORY=()
    ALL_CATEGORIES=()

    local current_category="基础"
    local line

    while IFS= read -r line; do
        [ -z "$line" ] && continue
        [[ "$line" =~ ^#.*格式 ]] && continue
        [[ "$line" =~ ^#.*分类说明 ]] && continue

        if [[ "$line" =~ ^#[[:space:]]*(=+) ]]; then
            local title raw_category
            title=$(echo "$line" | sed 's/^#[[:space:]]*//; s/[[:space:]]*=*//g')
            if [[ "$title" == *"（"* ]] || [[ "$title" == *"("* ]]; then
                raw_category=$(echo "$title" | sed 's/[（(].*//' | sed 's/[[:space:]]*$//')
            else
                raw_category="$title"
            fi

            current_category="$raw_category"
            if [ "$current_category" != "基础" ] && ! dotfiles_array_contains "$current_category" "${ALL_CATEGORIES[@]}"; then
                ALL_CATEGORIES+=("$current_category")
            fi
            continue
        fi

        [[ "$line" =~ ^# ]] && continue

        local first
        first=$(echo "$line" | cut -d':' -f1 | sed 's/[[:space:]]//g')

        case "$first" in
            包)
                local pkg_name
                pkg_name=$(echo "$line" | cut -d':' -f2 | sed 's/[[:space:]]//g')
                PACKAGES_BY_CATEGORY["$current_category"]="${PACKAGES_BY_CATEGORY[$current_category]:-} $pkg_name"
                ;;
            模块)
                local mod_name mod_category
                mod_name=$(echo "$line" | cut -d':' -f2 | sed 's/[[:space:]]//g')
                mod_category=$(echo "$line" | cut -d':' -f3 | sed 's/[[:space:]]//g')
                MODULES_BY_CATEGORY["$mod_category"]="${MODULES_BY_CATEGORY[$mod_category]:-} $mod_name"
                if ! dotfiles_array_contains "$mod_category" "${ALL_CATEGORIES[@]}"; then
                    ALL_CATEGORIES+=("$mod_category")
                fi
                ;;
        esac
    done < "$conf_file"
}

dotfiles_list_config_packages() {
    local conf_file="${1:-$DOTFILES_DIR/config/packages.conf}"
    local line first

    [ -f "$conf_file" ] || return 1

    while IFS= read -r line; do
        [ -z "$line" ] && continue
        [[ "$line" =~ ^# ]] && continue

        first=$(echo "$line" | cut -d':' -f1 | sed 's/[[:space:]]//g')
        if [ "$first" = "包" ]; then
            echo "$line" | cut -d':' -f2 | sed 's/[[:space:]]//g'
        fi
    done < "$conf_file"
}

dotfiles_select_packages_arg() {
    local selected_categories="$1"
    local cat pkg mod

    for cat in $selected_categories; do
        case "$cat" in
            基础)
                for pkg in ${PACKAGES_BY_CATEGORY["基础"]:-}; do
                    SELECTED_PACKAGES+=("$pkg")
                done
                ;;
            *)
                for pkg in ${PACKAGES_BY_CATEGORY[$cat]:-}; do
                    SELECTED_PACKAGES+=("$pkg")
                done
                for mod in ${MODULES_BY_CATEGORY[$cat]:-}; do
                    SELECTED_MODULES+=("$mod")
                done
                ;;
        esac
    done

    log_info "已选择 ${#SELECTED_PACKAGES[@]} 个包、${#SELECTED_MODULES[@]} 个模块"
}

dotfiles_select_all_packages() {
    local category pkg mod

    SELECTED_PACKAGES=()
    SELECTED_MODULES=()

    for pkg in ${PACKAGES_BY_CATEGORY["基础"]:-}; do
        SELECTED_PACKAGES+=("$pkg")
    done

    for category in "${ALL_CATEGORIES[@]}"; do
        [ "$category" = "基础" ] && continue
        [ "$category" = "模块" ] && continue

        for pkg in ${PACKAGES_BY_CATEGORY[$category]:-}; do
            SELECTED_PACKAGES+=("$pkg")
        done
        for mod in ${MODULES_BY_CATEGORY[$category]:-}; do
            SELECTED_MODULES+=("$mod")
        done
    done

    log_info "已选择全部 ${#SELECTED_PACKAGES[@]} 个包、${#SELECTED_MODULES[@]} 个模块"
}

dotfiles_select_packages_interactive() {
    echo ""
    echo -e "${DOTFILES_COLOR_BLUE}=======================================${DOTFILES_COLOR_RESET}"
    echo "     软件包和模块选择"
    echo -e "${DOTFILES_COLOR_BLUE}=======================================${DOTFILES_COLOR_RESET}"
    echo ""

    SELECTED_PACKAGES=()
    SELECTED_MODULES=()

    echo -e "${DOTFILES_COLOR_GREEN}基础（必装）${DOTFILES_COLOR_RESET}"
    local pkg
    for pkg in ${PACKAGES_BY_CATEGORY["基础"]:-}; do
        echo -e "  ${DOTFILES_COLOR_GREEN}[x]${DOTFILES_COLOR_RESET} $pkg"
        SELECTED_PACKAGES+=("$pkg")
    done
    echo ""

    local -a entries=()
    local modules_category="可插拔模块"
    local category mod

    for category in "${ALL_CATEGORIES[@]}"; do
        [ "$category" = "基础" ] && continue
        [ "$category" = "模块" ] && continue

        for pkg in ${PACKAGES_BY_CATEGORY[$category]:-}; do
            entries+=("$category::pkg::$pkg")
        done
        for mod in ${MODULES_BY_CATEGORY[$category]:-}; do
            entries+=("$modules_category::mod::$mod")
        done
    done

    local -a selected_flags=()
    local idx
    for ((idx=0; idx<${#entries[@]}; idx++)); do
        selected_flags[idx]=1
    done

    while true; do
        local global_idx=0
        local -a display_categories=()
        local -a display_to_entry_idx=()

        for category in "${ALL_CATEGORIES[@]}"; do
            [ "$category" = "基础" ] && continue
            [ "$category" = "模块" ] && continue
            display_categories+=("$category")
        done
        display_categories+=("$modules_category")

        for category in "${display_categories[@]}"; do
            echo "$category"

            local -a cat_items=()
            local -a cat_item_indexes=()
            local ent_i
            for ent_i in "${!entries[@]}"; do
                local ent="${entries[$ent_i]}"
                local ent_cat="${ent%%::*}"
                if [ "$ent_cat" = "$category" ]; then
                    cat_items+=("$ent")
                    cat_item_indexes+=("$ent_i")
                fi
            done

            local total=${#cat_items[@]}
            local i
            for ((i=0; i<total; i++)); do
                global_idx=$((global_idx + 1))
                local ent="${cat_items[$i]}"
                local rest="${ent#*::}"
                local ent_type="${rest%%::*}"
                local ent_name="${rest#*::}"
                local display_name="$ent_name"
                [ "$ent_type" = "mod" ] && display_name="[$ent_name]"
                local real_idx="${cat_item_indexes[$i]}"
                display_to_entry_idx[$global_idx]="$real_idx"
                local mark="[ ]"
                [ "${selected_flags[$real_idx]}" = "1" ] && mark="${DOTFILES_COLOR_GREEN}[x]${DOTFILES_COLOR_RESET}"
                printf "  %b [%s] %-16s" "$mark" "$global_idx" "$display_name"
                if (( (global_idx % 2 == 0) || i + 1 == total )); then echo ""; fi
            done
            echo ""
        done

        echo "输入编号/范围切换选择（如 3 8-12），a=全选，n=全不选，回车或 q=确认："
        local reply
        read -r reply

        [ -z "$reply" ] && break
        [ "$reply" = "q" ] && break

        if [ "$reply" = "a" ]; then
            for ((idx=0; idx<${#entries[@]}; idx++)); do selected_flags[idx]=1; done
            echo ""
            continue
        fi

        if [ "$reply" = "n" ]; then
            for ((idx=0; idx<${#entries[@]}; idx++)); do selected_flags[idx]=0; done
            echo ""
            continue
        fi

        local token
        for token in $reply; do
            if [[ "$token" == *-* ]]; then
                local start_num="${token%%-*}"
                local end_num="${token#*-}"
                if [[ "$start_num" =~ ^[0-9]+$ && "$end_num" =~ ^[0-9]+$ ]]; then
                    local n
                    for ((n=start_num; n<=end_num; n++)); do
                        if ((n >= 1 && n <= global_idx)); then
                            local flag_idx="${display_to_entry_idx[$n]}"
                            [ -z "$flag_idx" ] && continue
                            if [ "${selected_flags[$flag_idx]}" = "1" ]; then
                                selected_flags[$flag_idx]=0
                            else
                                selected_flags[$flag_idx]=1
                            fi
                        fi
                    done
                fi
            elif [[ "$token" =~ ^[0-9]+$ ]]; then
                local num="$token"
                if ((num >= 1 && num <= global_idx)); then
                    local flag_idx="${display_to_entry_idx[$num]}"
                    [ -z "$flag_idx" ] && continue
                    if [ "${selected_flags[$flag_idx]}" = "1" ]; then
                        selected_flags[$flag_idx]=0
                    else
                        selected_flags[$flag_idx]=1
                    fi
                fi
            fi
        done
        echo ""
    done

    local ent_i
    for ent_i in "${!entries[@]}"; do
        [ "${selected_flags[$ent_i]}" = "1" ] || continue

        local ent="${entries[$ent_i]}"
        local rest="${ent#*::}"
        local ent_type="${rest%%::*}"
        local ent_name="${rest#*::}"
        [ "$ent_type" = "pkg" ] && SELECTED_PACKAGES+=("$ent_name")
        [ "$ent_type" = "mod" ] && SELECTED_MODULES+=("$ent_name")
    done

    if [ ${#SELECTED_PACKAGES[@]} -eq 0 ] && [ ${#SELECTED_MODULES[@]} -eq 0 ]; then
        log_warning "未选择任何包"
    else
        log_info "已选择 ${#SELECTED_PACKAGES[@]} 个包、${#SELECTED_MODULES[@]} 个模块"
    fi
}
