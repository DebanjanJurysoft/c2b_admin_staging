<template>
    <div class="category-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="tabs-content">
            <div class="d-flex flex-row-reverse mb-3">
                <b-button variant="outline-success" @click.prevent="addAttribute"><i class="fa fa-plus"></i></b-button>
                <vSelect style="width: 100% !important;" class="col-4 mr-2" label="text" 
                    v-model="filter_selected_category" :options="category_list">
                </vSelect>
            </div>
            <table class="table table-hover">
                <thead>
                    <th style="text-transform: uppercase;">SL No.</th>
                    <th style="text-transform: uppercase;">category</th>
                    <th style="text-transform: uppercase;">attribute name</th>
                    <th style="text-transform: uppercase; text-align: center;">Action</th>
                </thead>
                <tbody>
                    <tr v-for="(attribute, attribute_index) in attribute_list">
                        <td>{{ attribute_index + 1 }}</td>
                        <td>{{ attribute.category }}</td>
                        <td>{{ attribute.attribute_name }}</td>
                        <td style="text-align: center;">
                            <b-button variant="outline-primary" @click.prevent="editData(attribute)"><i class="fa fa-pencil"></i></b-button>
                            <b-button variant="outline-danger" @click.prevent="removeAttribute(attribute.id)"><i class="fa fa-trash"></i></b-button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <b-modal
            id="attributes" 
            hide-footer 
            hide-header 
            no-close-on-backdrop 
            centered 
        >
            <div class="d-flex align-items-center justify-content-between mb-4">
                <span>{{edit_id ? 'Update' : 'Add New'}} Attribute</span>
                <button class="btn btn-outline-danger" @click.prevent="closeModal"><i class="fa fa-times"></i></button>
            </div>
            <div class="d-flex flex-column py-2">
                <span>Category: </span>
                <vSelect style="width: 100% !important;" label="text" value="value"
                    v-model="selected_category" :options="category_list">
                </vSelect>
            </div>
            <div class="d-flex flex-column py-2">
                <span>Attribute Name: </span>
                <b-form-input v-model="attribute_name" placeholder="Attribute Name"></b-form-input>
            </div>
            <div class="d-flex flex-row py-2 justify-content-center" style="gap: 10px;">
                <button class="btn btn-outline-success" @click.prevent="saveAttribute"><i class="fa fa-save mr-2"></i>SAVE</button>
                <button class="btn btn-outline-danger" @click.prevent="closeModal"><i class="fa fa-times mr-2"></i>CLOSE</button>
            </div>
        </b-modal>
    </div>
</template>

<script>
import vSelect from 'vue-select';
export default {
    components: {
        vSelect
    },
    data() {
        return {
            loader: false,
            attribute_list: [],
            fields: ['id', 'category', 'attribute_name', 'action'],
            selected_category: null,
            category_list: [],
            filter_selected_category: null,
            attribute_name: null,
            edit_id: null
        }
    },
    async mounted() {
       this.loader = true
       await this.fetchAttributes()
       await this.fetchCategories()
       this.loader = false
    },
    watch: {
        filter_selected_category() {
            this.fetchAttributes()
        }
    }, 
    methods: {
        async editData(data) {
            this.edit_id = data.id
            this.selected_category = data.category_data
            this.attribute_name = data.attribute_name
            this.openModal()
        },
        async removeAttribute(id) {
            this.deleteAttribute('/delete-attribute', 'attribute_id', id)
        },
        async deleteAttribute(path, key, data_id) {
            try {
                const h = this.$createElement
                const id = `DeleteModal${id}`
                this.$bvToast.hide(id)
                const $closeButton = h(
                'b-button',
                {
                    on: { click: () => this.$bvToast.hide(id) },
                    class: 'btn btn-primary mx-1',
                    style: 'margin: 0 auto;'
                },
                'No'
                )
                const $acceptButton = h(
                'b-button',
                {
                    on: {
                        click: async () => {
                            let data = {}
                            data[key] = data_id
                            const deleteresponse = await this.$axios.post(path, data)
                            this.$toast.show(deleteresponse.data.message, {
                                duration: 1500,
                                position: 'top-right',
                                keepOnHover: true,
                                type: deleteresponse.data.status
                            })
                            await this.fetchAttributes()
                            this.$bvToast.hide(id)
                        }
                    },
                    class: 'btn btn-danger mx-1',
                },
                'Yes'
                )
                const $buttonContainer = h(
                    'div',
                    {
                        class: 'text-center my-2',
                    },
                    [$closeButton, $acceptButton]
                )
                this.$bvToast.toast($buttonContainer, {
                    id: id,
                    title: `Are you sure?`,
                    noCloseButton: true,
                })
            } catch (error) {
                console.log(error);
            }
        },
        async updateAttribute() {
            try {
                if (!this.selected_category) {
                    this.$toast.show('Select a category.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                }
                if (!this.attribute_name) {
                    this.$toast.show('Enter a attribute name.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                }
                const response = await this.$axios({
                    method: 'POST',
                    url: '/update-attributes',
                    data: {
                        attribute_id: this.edit_id,
                        category_id: this.selected_category.value,
                        attribute_name: this.attribute_name
                    }
                })
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                await this.fetchAttributes()
                this.resetForm()
            } catch (error) {
                console.log(error);
            }
        },
        async saveAttribute() {
            try {
                if (this.edit_id) {
                    await this.updateAttribute()
                    return
                }
                if (!this.selected_category) {
                    this.$toast.show('Select a category.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                }
                if (!this.attribute_name) {
                    this.$toast.show('Enter a attribute name.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true,
                        type: 'error'
                    })
                }
                const response = await this.$axios({
                    method: 'POST',
                    url: '/add-attributes',
                    data: {
                        category_id: this.selected_category.value,
                        attribute_name: this.attribute_name
                    }
                })
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                await this.fetchAttributes()
                this.resetForm()
            } catch (error) {
                console.log(error);
            }
        },
        resetForm() {
            this.selected_category = null
            this.edit_id = null
            this.closeModal()
        },
        addAttribute() {
            this.selected_category = this.category_list[0]
            this.openModal()
        },
        openModal() {
            this.$bvModal.show('attributes')
        },
        closeModal() {
            this.$bvModal.hide('attributes')
        },
        async fetchAttributes() {
            try {
                let url = '/fetch-attributes'
                if (this.filter_selected_category.value) {
                    url = `${url}?category_id=${this.filter_selected_category.value}`
                }
                console.log(url);
                const response = await this.$axios.get(url)
                this.attribute_list = response.data.attributes.map(e => {
                    return {
                        id: e.id,
                        category: e.category_table_association.category_name,
                        attribute_name: e.attribute_name,
                        category_data: {
                            value: e.category_id,
                            text: e.category_table_association.category_name
                        },
                        _action: true
                    }
                })
            } catch (error) {
                console.log(error);
            }
        },
        async fetchCategories() {
            try {
                let url = '/get-categories-vendor-registration'
                const response = await this.$axios.get(url)
                this.category_list = response.data.product_types.map(e => {
                    return {
                        value: e.id,
                        text: e.category_name
                    }
                })
                this.category_list.unshift({
                    value: null,
                    text: 'Select the category'
                })
                this.filter_selected_category = this.category_list[0]
            } catch (error) {
                console.log(error);
            }
        }
    }
}
</script>