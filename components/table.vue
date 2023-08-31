<template>
    <div class="table-container" v-if="data_rows.length > 0">
        <table class="main-table">
            <thead>
                <th class="heading" v-for="(head, head_index) in headings" :key="head_index"><i v-if="head.icon" :class="head.icon"></i>{{ head.name }}</th>
            </thead>
            <tbody>
                <tr class="table-rows" v-for="(row, row_index) in data_rows" :key="row_index">
                    <template v-for="(head, head_index) in headings">
                        <td :key="head_index" v-if="head.name != 'action'">{{ row[head.name] }}</td>
                        <td v-if="head.name == 'action'" class="d-flex flex-wrap">
                            <template v-for="(buttons, action_button_index) in head.buttons">
                                <i @click.prevent="emitData(buttons.emit_name, row.id)" v-if="!buttons.text" class="px-1" :style="`color: ${buttons.color}; cursor: pointer;`" :key="action_button_index" :class="buttons.icon"></i>
                                <button v-if="buttons.text" @click.prevent="emitData(buttons.emit_name, row.id)" :style="`background: ${color}; color: #fff; cursor: pointer;`"><i v-if="buttons.icon" :class="buttons.icon"></i>{{ buttons.text }}</button>
                            </template>
                        </td>
                    </template>
                </tr>
            </tbody>
        </table>
    </div>
    <div class="table-container" v-else>
        <h3 class="w-100 text-center my-5">No records found</h3>
    </div>
</template>

<script>
export default {
    props: ['headings', 'data_rows'],
    methods: {
        emitData(emitMethod, id) {
            this.$emit('callFunction', {
                emitMethod,
                id
            })
        }
    }
}
</script>