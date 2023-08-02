<template>
    <div class="w-100 apartmentHolder">
        <div class="addApartment card" style="height: 750px;">
            <div class="text-center">
                <h3>{{ `${addApartment ? 'Add' : 'Update'} Block` }}</h3>
                <div class="p-3">
                    <div class="row align-items-center">
                        <label class="col-4">Project</label>
                        <b-select class="select-box col-8" @change="createBlockList" v-model="selected_project" :disabled="project_list.length == 1" :options="project_list" value-field="id" text-field="project_name"></b-select>
                    </div>
                </div>
                <div class="p-3" v-if="selected_project">
                    <div class="row align-items-center">
                        <label class="col-4">Block</label>
                        <b-select class="select-box col-8" @change="createApartmentName" v-model="selected_block" :options="block_list"></b-select>
                    </div>
                </div>
                <div class="p-3"  v-if="selected_project && selected_block">
                    <div class="row align-items-center">
                        <label class="col-4">Building</label>
                        <input type="text" class="col-8" v-model="apartment_name" placeholder="Block Name">
                    </div>
                </div>
                <div class="p-3"  v-if="selected_project && selected_block">
                    <div class="row align-items-center">
                        <label class="col-4">Floors</label>
                        <input type="number" class="col-8" @input="() => {floor_list = Array.from(Array(parseInt(no_of_floor ? no_of_floor : 0)).keys()).map(e => { return {floors: e+1, units: 0, disabled: false}})}" v-model="no_of_floor" placeholder="Floors In The Block">
                    </div>
                </div>
                <div v-if="selected_project && selected_block" style="height: 200px; overflow-x: hidden; overflow: auto;">
                    <div class="p-3 d-flex align-items-center" v-if="floor_list.length > 0" v-for="(floor, index) in floor_list">
                        <label class="col-6">Units (FL-{{ floor.floors}})</label>
                        <input class="col-4 " @input="changeAll" :disabled="floor.disabled" type="number" v-model="floor.units">
                    </div>
                </div>
                <div>
                    <b-checkbox v-model="same_for_all" @change="sameForAll" v-if="floor_list.length > 0">Same For All</b-checkbox>
                </div>
                <div class="p-3">
                    <button class="btn2" @click.prevent="resetForm()" v-if="updateApartment"><i class="fa fa-ban"></i> CANCEL</button>
                    <button class="btn2" @click.prevent="saveForm()"><i class="fa fa-save"></i> SAVE</button>
                </div>
            </div>
        </div>
        <div class="viewApartment card" style="height: 750px; padding: 30px; overflow-y: scroll;" v-if="apartmentList.length > 0">
            <table class="table table-striped">
                <thead style="background: #2c2c2c;">
                    <tr style="font-weight: 700; color: white; text-align: center;">
                        <td>Block Name</td>
                        <td>No Of Floors</td>
                        <td>Total No Of Units</td>
                        <td>Action</td>
                    </tr>
                </thead>
                <tbody>
                    <tr  v-for="(apartment, index) in apartmentList" :key="index">
                        <td>{{ apartment.name }}</td>
                        <td>{{ apartment.floor_no }}</td>
                        <td>{{ apartment.total_units }}</td>
                        <td style="width: 120px;">
                            <i style="cursor: pointer;" @click.prevent="openUnit(apartment.id)" class="fa fa-eye mr-1 text-success" ></i>
                            <i style="cursor: pointer;" @click.prevent="editApartment(apartment.id)" class="fa fa-pencil mr-1 text-warning" ></i>
                            <i style="cursor: pointer;" @click.prevent="deleteApartment(apartment.id)" class="fa fa-trash text-danger"></i>
                        </td>
                    </tr>
                </tbody>
            </table>
            <!-- <div class="card my-2" style="width: 100%;" v-for="(apartment, index) in apartmentList" :key="index">
                <div class="card-body"> 
                    <h5 class="card-title">{{ apartment.name }}</h5>
                    <p class="card-text">Number of floors: {{ apartment.floor_no }}</p>
                    <p class="card-text">Total units: {{ apartment.total_units }}</p>
                    <button class="btn2 mr-2" @click.prevent="editApartment(apartment.id)"><i class="fa fa-pencil"></i> EDIT</button>
                    <button class="btn2" @click.prevent="deleteApartment(apartment.id)"><i class="fa fa-trash"></i> DELETE</button>
                </div>
            </div> -->
        </div>
        <div class="viewApartment" v-else>
            <div class="card my-2">
                <div class="card-body">
                    <h5 class="card-title">No Blocks found.</h5>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Swal from 'sweetalert2'
export default {
    data() {
        return {
            addApartment: true,
            same_for_all: false,
            viewApartment: true,
            updateApartment: false,
            apartment_name: null,
            no_of_floor: null,
            unit_per_floor: null,
            edit_id: null,
            apartmentList: [],
            floor_list: [],
            project_list: [],
            selected_project: null,
            block_list: [],
            selected_block: null,
        }
    },
    mounted() { 
        this.fetchProject()
        this.fetchApartments()
    },
    methods: {
        openUnit(apt_id) { 
            localStorage.setItem('apartment', apt_id)
            this.$emit('changeTabOnChange', 'UNITS')
        },
        createApartmentName() { 
            const project = this.project_list.find(e => e.id == this.selected_project)
            const apt_name = `${project.project_name} (Block-${this.selected_block})`
            this.apartment_name = apt_name
        },
        createBlockList() { 
            this.block_list = []
            const project = this.project_list.find(e => e.id == this.selected_project)
            for (let i = 1; i <= project.blocks; i++) {
                this.block_list.push({
                    value: i,
                    text: i
                })
            }
            // console.log(this.block_list);
            this.block_list.unshift({
                value: null,
                text: 'Select a block'
            })
        },
        async fetchProject() {
            let query = {}
            if (localStorage.getItem('project')) {
                query = {
                    id: parseInt(localStorage.getItem('project'))
                }
            }
            const response = await this.$axios.get('/get-project', { params: query })
            if (response.data.data.length == 1) {
                this.selected_project = response.data.data[0].id
                this.block_list = []
                for (let i = 1; i <= response.data.data[0].blocks; i++) {
                    this.block_list.push({
                        value: i,
                        text: i
                    })
                }
                this.block_list.unshift({
                    value: null,
                    text: 'Select a block'
                })
            }
            this.project_list = response.data.data
            this.project_list.unshift({
                    id: null,
                    project_name: 'Select a project'
                })
        },
        changeAll() { 
            if (this.same_for_all) {
                this.floor_list.forEach((e, i) => {
                    e.units = this.floor_list[0].units ? this.floor_list[0].units : 0
                })
            }
        },
        sameForAll() { 
            if (this.same_for_all) {
                this.floor_list.forEach((e, i) => {
                    if (this.floor_list[0].units) {
                        e.units = this.floor_list[0].units
                    }
                    if (i != 0) {
                        e.disabled = true
                    }
                })
            } else {
                this.floor_list.forEach(e => {
                    e.disabled = false
                })
            }
        },
        async fetchApartments() { 
            const response = await this.$axios.get('/get-apartments')
            this.apartmentList = response.data.data.map(e => { 
                let  totalUnits = 0
                e.floors.forEach(elm => {
                    totalUnits += parseInt(elm.units)
                })
                return {
                    ...e, 
                    total_units: totalUnits
                }
            })
        },
        deleteApartment(id) {
            Swal.fire({
                title: 'Are you sure?',
                text: "You won't be able to revert this!",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes, delete it!'
            }).then(async (result) => {
                if (result.isConfirmed) {
                    const response = await this.$axios.post('/delete-apartment', {
                        id: id
                    })
                    // console.log(response);
                    Swal.fire({
                        position: 'top-end',
                        icon: response.data.message.includes('success') ? 'success' : 'error',
                        title: response.data.message,
                        showConfirmButton: false,
                        timer: 1500
                    })
                    this.fetchApartments()
                }
            })
        },
        resetForm() { 
            this.apartment_name = null
            this.no_of_floor = null
            this.unit_per_floor = null
            this.updateApartment = false
            this.addApartment = true
            localStorage.removeItem('project')
            this.selected_project = null
            this.fetchProject()
            this.floor_list = []
        },
        editApartment(id) {
            const selectedApartment = this.apartmentList.find(e => e.id == id)
            const project = selectedApartment.name.split(' ')[0]
            const project_id = this.project_list.find(e => e.project_name == project).id
            localStorage.setItem('project', project_id)
            const block = parseInt(selectedApartment.name.split('-')[1].replace(')',''))
            this.selected_block = block
            this.fetchProject()
            this.edit_id = id
            this.apartment_name = selectedApartment.name
            this.no_of_floor = selectedApartment.floor_no
            this.unit_per_floor = selectedApartment.unit_per_floor
            this.floor_list = selectedApartment.floors
            this.updateApartment = true
            this.addApartment = false
        },
        async saveForm() {
            if (!this.apartment_name || !this.apartment_name.trim()) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter apartment name.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            if (!this.no_of_floor || !`${this.no_of_floor}`.trim()) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter number of floors.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            if (!this.floor_list.length > 0 || this.floor_list.filter(e => e.units == 0).length > 0 ) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter unit no for each floor.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            let payload = {}
            if (this.updateApartment) {
                payload = {
                    id: this.edit_id,
                    name: this.apartment_name,
                    floor_no: this.no_of_floor,
                    unit_per_floor_data: this.floor_list.map(e => {
                        return {
                            id: e.id,
                            floor_no: parseInt(e.floors),
                            unit_no: parseInt(e.units)
                        }
                    })
                }
                const response = await this.$axios.post('/update-apartment', payload)
                Swal.fire({
                    position: 'top-end',
                    icon: response.data.message.includes('success') ? 'success' : 'error',
                    title: response.data.message,
                    showConfirmButton: false,
                    timer: 1500
                })
                this.resetForm()
                this.fetchApartments()
            } else {
                payload = {
                    name: this.apartment_name,
                    floor_no: this.no_of_floor,
                    unit_per_floor_data: this.floor_list.map(e => {
                        return {
                            floor_no: e.floors,
                            unit_no: parseInt(e.units)
                        }
                    })
                }
                // console.log(payload);
                const response = await this.$axios.post('/add-apartment', payload)
                Swal.fire({
                    position: 'top-end',
                    icon: response.data.message.includes('success') ? 'success' : 'error',
                    title: response.data.message,
                    showConfirmButton: false,
                    timer: 1500
                })
                this.resetForm()
                this.fetchApartments()
            }
        }
    }
}
</script>

<style>
.apartmentHolder {
    width: 100%;
    height: max-content;
    justify-content: space-evenly;
    display: flex;
}
.addApartment {
    width: 40%;
    float: left;
    margin-right: 30px;
}

.viewApartment {
    width: 60%;
    float: left;
}
</style>