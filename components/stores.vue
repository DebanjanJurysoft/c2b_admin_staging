<template>
  <div class="category-container">
    <div v-if="loader" class="loader">
      <Loader />
    </div>
    <div v-if="!loader" class="tabs-content">
      <div class="d-flex flex-row w-100" style="gap: 30px">
        <div
          class="d-flex flex-column"
          style="
            cursor: pointer;
            width: 40% !important;
            gap: 10px;
            height: 100% !important;
            overflow-y: scroll;
          "
        >
          <div
            class="d-flex flex-row align-items-center justify-content-between"
          >
            <h1
              class="heading"
              style="
                font-size: 20px;
                background: none;
                border: none;
                color: black;
              "
            >
              Stores
            </h1>
          </div>
          <div
            class="card"
            v-for="(store, store_index) in store_list"
            style="border-radius: 16px"
            @click.prevent="showStoreForIndex(store_index)"
          >
            <div
              class="d-flex flex-row py-3 pl-5 pr-3 justify-content-between align-items-center"
              :style="
                store_index == selected_store_index
                  ? 'border-radius: 16px; border: 2px solid #e74c3c; box-shadow: 0px 0px 12px 0px rgba(0, 0, 0, 0.12);'
                  : ''
              "
            >
              <div class="d-flex flex-row" style="gap: 10px">
                <img
                  style="
                    border-radius: 16px;
                    height: 60px !important;
                    width: 100px !important;
                    object-fit: cover;
                  "
                  :src="store.store_image_url"
                  width="100"
                  alt="Image"
                />
                <div class="d-flex flex-column">
                  <span
                    class="heading"
                    style="font-size: 16px; background: none; border: none"
                    >Store: {{ store.name }}</span
                  >
                  <span
                    class="heading"
                    style="
                      font-size: 12px;
                      line-height: 1px;
                      background: none;
                      border: none;
                    "
                    >Vendor:
                    {{
                      store?.vendor?.fullname ? store?.vendor?.fullname : "N/A"
                    }}</span
                  >
                </div>
              </div>
              <i
                v-b-tooltip.hover
                title="Branches"
                class="fa fa-sitemap"
                style="
                  font-size: 20px;
                  background: none;
                  border: none;
                  color: #667085;
                "
              ></i>
            </div>
          </div>
        </div>
        <div
          class="d-flex flex-column p-2"
          style="
            width: 60% !important;
            gap: 10px;
            height: 100% !important;
            overflow-y: scroll;
          "
          v-if="selected_store_index != null && !open_form"
        >
          <div
            class="d-flex flex-row align-items-center justify-content-between"
          >
            <h1
              class="text-heading"
              style="
                font-size: 20px;
                background: none;
                border: none;
                color: black;
              "
            >
              Branches ({{ branch_list.length }})
            </h1>
            <div class="d-flex flex-row" style="gap: 10px">
              <button class="button" @click.prevent="openCreateForm">
                <i
                  style="font-size: 18px"
                  class="fa fa-plus-circle"
                  aria-hidden="true"
                  ><span class="pl-2">Branches</span></i
                >
              </button>
              <button class="button" @click.prevent="openSettings">
                <i style="font-size: 18px" class="fa fa-cog" aria-hidden="true"
                  ><span class="pl-2">Store Settings</span></i
                >
              </button>
            </div>
          </div>
          <div v-if="open_settings">
            <div class="d-flex flex-row mb-3">
              <div
                class="tab-items"
                @click.prevent="changeTab(tabs)"
                :style="
                  selected_tab == tabs
                    ? 'color: black;'
                    : 'color: rgb(120 120 120);'
                "
                :class="selected_tab == tabs ? 'tab-items-active' : ''"
                v-for="(tabs, tabs_index) in inner_tabs"
              >
                <i :class="tabs.icon" class="mr-2"></i>{{ tabs.name }}
              </div>
            </div>
            <div class="card sub-category-form" v-if="open_store_image_form">
              <div
                style="width: 100% !important"
                class="mb-2 d-flex flex-row align-items-center"
              >
                <span
                  class="heading"
                  style="
                    padding-left: 0px !important;
                    font-size: 20px;
                    background: none;
                    border: none;
                  "
                  >Store Image</span
                >
              </div>
              <div class="d-flex flex-row align-items-center">
                <b-form-file
                  @input="changeStoreImage($event)"
                  v-model="store_image"
                ></b-form-file>
                <div class="d-flex flex-column px-3" v-if="store_image_url">
                  <img
                    style="width: 100px; border-radius: 16px"
                    :src="store_image_url"
                    alt="Image"
                  />
                </div>
              </div>
              <div class="d-flex flex-row justify-content-center pt-3">
                <button class="button" @click.prevent="saveStoreImage">
                  <i class="fa fa-save mr-2"></i> Save Store Image
                </button>
              </div>
            </div>
            <div class="card sub-category-form" v-if="open_store_timings_form">
              <div
                style="width: 100% !important"
                class="mb-2 d-flex flex-row align-items-center"
              >
                <span
                  class="heading"
                  style="font-size: 20px; background: none; border: none"
                  >Store Timings</span
                >
              </div>
              <div class="d-flex flex-column" style="gap: 5px">
                <div
                  class="d-flex flex-row align-items-center"
                  style="gap: 5px"
                  v-for="(days, days_index) in store_timings_form"
                >
                  <div style="width: 26% !important">
                    <span class="text-heading">{{ days.day }}</span>
                  </div>
                  <div style="width: 30% !important">
                    <b-form-timepicker
                      :disabled="!days.is_open"
                      v-model="days.open_time"
                      placeholder="time"
                      locale="en"
                    ></b-form-timepicker>
                  </div>
                  <div style="width: 30% !important">
                    <b-form-timepicker
                      :disabled="!days.is_open"
                      v-model="days.close_time"
                      placeholder="time"
                      locale="en"
                    ></b-form-timepicker>
                  </div>
                  <div style="width: 24% !important">
                    <b-form-select
                      v-model="days.is_open"
                      :options="store_status_options"
                    ></b-form-select>
                  </div>
                </div>
              </div>
              <div class="d-flex flex-row justify-content-center pt-3">
                <button class="button" @click.prevent="saveStoreTimings">
                  <i class="fa fa-save mr-2"></i> Save Store Timings
                </button>
              </div>
            </div>
            <div class="card sub-category-form" v-if="open_store_delivery_form">
              <div
                style="width: 100% !important"
                class="mb-2 d-flex flex-row align-items-center justify-content-between"
              >
                <span
                  class="heading"
                  style="font-size: 20px; background: none; border: none"
                  >Store Delivery</span
                >
                <span class="text-heading"
                  >Service Radius: {{ store_service_radius }}</span
                >
                <!-- <div class="d-flex flex-row">
                                    <b-form-select style="width: 20% !important" placeholder="Service Radius" disabled v-model="store_service_radius" :options="store_service_radius_option"></b-form-select>
                                </div> -->
              </div>
              <div class="d-flex flex-column" style="gap: 10px">
                <div
                  class="d-flex flex-row"
                  style="gap: 10px"
                  v-for="(del, del_index) in store_delivery_form"
                >
                  <span
                    style="
                      width: 20% !important;
                      max-width: 20% !important;
                      min-height: 20% !important;
                    "
                    class="text-heading"
                    >{{ `${del.km} KM` }}</span
                  >
                  <b-form-input
                    style="width: 40% !important"
                    v-model="del.time"
                    placeholder="Time in minute"
                  ></b-form-input>
                  <b-form-input
                    style="width: 40% !important"
                    v-model="del.price"
                    placeholder="Price"
                  ></b-form-input>
                </div>
              </div>
              <div class="d-flex flex-row justify-content-center pt-3">
                <button
                  class="button"
                  @click.prevent="saveStoreDeliveryPriceDetails"
                >
                  <i class="fa fa-save mr-2"></i> Save Store Delivery Details
                </button>
              </div>
            </div>
            <div class="card sub-category-form" v-if="open_other_settings_form">
              <div
                class="d-flex flex-row-reverse justify-content-between align-items-center py-2"
              >
                <b-form-radio-group
                  id="btn-radios-2"
                  v-model="other_setting_data.store_open_close"
                  :options="store_open_close_type"
                  :button-variant="
                    other_setting_data.store_open_close == true
                      ? 'outline-success'
                      : 'outline-danger'
                  "
                  size="sm"
                  name="radio-btn-outline"
                  buttons
                ></b-form-radio-group>
                <span
                  class="text-heading"
                  style="
                    font-size: 25px !important;
                    padding-left: 0px !important;
                    font-weight: 500 !important;
                  "
                  >Other settings</span
                >
              </div>
              <div class="d-flex flex-column">
                <div
                  class="d-flex flex-column py-2"
                  style="justify-content: space-between"
                >
                  <div class="d-flex flex-row" style="width: 100% !important">
                    <b-form-checkbox
                      switch
                      v-model="other_setting_data.free_delivery"
                    >
                      <span
                        class="text-heading"
                        style="
                          font-size: 16px !important;
                          padding-left: 0px !important;
                          font-weight: 500 !important;
                        "
                        >Free Delivery Available</span
                      >
                    </b-form-checkbox>
                  </div>
                  <span
                    class="text-heading"
                    style="
                      width: 100% !important;
                      padding-left: 0px !important;
                      font-size: 12px !important;
                      padding-left: 0px !important;
                      font-weight: 300 !important;
                    "
                    >Free delivery if amount is more than</span
                  >
                  <b-form-input
                    v-model="other_setting_data.free_delivery_if_more"
                    style="width: 100% !important; margin-top: -6px !important"
                    type="text"
                    placeholder="₹ 000"
                  />
                </div>
                <div
                  class="d-flex flex-column py-4"
                  style="justify-content: space-between"
                >
                  <div class="d-flex flex-row" style="width: 100% !important">
                    <b-form-checkbox
                      switch
                      v-model="other_setting_data.exchange"
                      ><span
                        class="text-heading"
                        style="
                          font-size: 16px !important;
                          padding-left: 0px !important;
                          font-weight: 500 !important;
                        "
                        >Exchange Available</span
                      ></b-form-checkbox
                    >
                  </div>
                  <div
                    class="d-flex flex-column"
                    style="width: 100% !important"
                  >
                    <span
                      class="text-heading"
                      style="
                        width: 100% !important;
                        padding-left: 0px !important;
                        font-size: 12px !important;
                        padding-left: 0px !important;
                        font-weight: 300 !important;
                      "
                      >Exchange Policy</span
                    >
                    <div class="d-flex flex-row align-items-center mb-2">
                      <b-form-textarea
                        v-model="other_setting_data.policies"
                        placeholder="Exchange Policies"
                        rows="3"
                        no-resize
                      ></b-form-textarea>
                    </div>
                  </div>
                </div>
                <div
                  class="d-flex flex-column mb-4"
                  style="justify-content: space-between"
                >
                  <span
                    class="text-heading"
                    style="
                      width: 100% !important;
                      font-size: 16px !important;
                      padding-left: 0px !important;
                      font-weight: 500 !important;
                      margin-top: -20px;
                      margin-bottom: 10px;
                    "
                    >Packing Charges</span
                  >
                  <b-form-input
                    v-model="other_setting_data.packing_charges"
                    style="width: 100% !important; margin-top: -6px !important"
                    type="text"
                    placeholder="₹ 000"
                  />
                </div>
                <div
                  class="d-flex flex-column"
                  style="justify-content: space-between"
                >
                  <div class="d-flex flex-row" style="width: 100% !important">
                    <b-form-checkbox
                      switch
                      v-model="other_setting_data.negociation"
                      ><span
                        class="text-heading"
                        style="
                          font-size: 16px !important;
                          padding-left: 0px !important;
                          font-weight: 500 !important;
                        "
                        >Negociation Available</span
                      ></b-form-checkbox
                    >
                  </div>
                </div>
                <div class="d-flex flex-row justify-content-center">
                  <button class="button" @click.prevent="saveOtherData">
                    <i class="fa fa-save mr-2"></i> Save
                  </button>
                </div>
              </div>
            </div>
          </div>
          <!-- <div class="card  sub-category-form">
                        <div style="width: 100% !important" class="mb-2 d-flex flex-row align-items-center justify-content-center">
                            <span class="heading" style="font-size: 20px; background: none; border: none;" >Store Delivery</span>
                        </div>
                        <div class="d-flex flex-column" style="gap: 5px;">
                            <div class="d-flex flex-row align-items-center" style="gap: 5px" v-for="(days, days_index) in store_timings_form">
                                <div style="width: 26% !important;">
                                    <span class="text-heading">{{ days.day }}</span>
                                </div>
                                <div style="width: 30% !important;">
                                    <b-form-timepicker :disabled="!days.is_open" v-model="days.open_time" placeholder="time" locale="en"></b-form-timepicker>
                                </div>
                                <div style="width: 30% !important;">
                                    <b-form-timepicker :disabled="!days.is_open" v-model="days.close_time" placeholder="time" locale="en"></b-form-timepicker>
                                </div>
                                <div style="width: 24% !important;">
                                    <b-form-select v-model="days.is_open" :options="store_status_options"></b-form-select>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex flex-row justify-content-center pt-3">
                            <button class="button" @click.prevent="saveStoreTimings">Save Store Timings</button>
                        </div>
                    </div> -->
          <div
            class="card sub-category-form"
            style="background: white; cursor: pointer"
            v-if="!open_settings && branch_list.length > 0"
            v-for="(branch, branch_index) in branch_list"
            :key="branch_index"
            @click.prevent="
              () => {
                if (!branch.collapse_active) {
                  openBranchDetails(branch, branch_index);
                }
              }
            "
            :style="
              branch.collapse_active
                ? 'border-radius: 16px; border: 2px solid #e74c3c; box-shadow: 0px 0px 12px 0px rgba(0, 0, 0, 0.12);'
                : ''
            "
          >
            <div
              class="d-flex flex-row"
              :class="branch.collapse_active ? 'mb-3' : ''"
              @click.prevent="
                () => {
                  if (branch.collapse_active) {
                    closeBranchDetails(branch_index);
                  }
                }
              "
            >
              <div style="width: 25% !important">
                <img
                  style="
                    border-radius: 16px;
                    height: 60px !important;
                    width: 100px !important;
                    object-fit: cover;
                  "
                  :src="branch.image_url"
                  alt="Branch Image"
                />
              </div>
              <div
                style="width: 65% !important"
                class="d-flex flex-row align-items-center"
              >
                <span
                  class="heading"
                  style="font-size: 20px; background: none; border: none"
                  >{{ branch.branch_name }}</span
                >
              </div>
              <!-- <div style="width: 5% !important;" class="d-flex flex-row align-items-center float-right">
                                <i @click.prevent="openStoreTimingDetails(branch, branch_index)" :style="branch.branch_timings ? 'color: #e74c3c' : 'color: #000000'" class="fa fa-clock-o cursor-pointer"></i>
                            </div> -->
              <div
                style="width: 10% !important"
                class="d-flex flex-row-reverse align-items-center float-right"
              >
                <i
                  :style="
                    branch.collapse_active ? 'color: #e74c3c' : 'color: #000000'
                  "
                  :class="
                    branch.collapse_active
                      ? 'fa fa-angle-up cursor-pointer'
                      : 'fa fa-angle-down cursor-pointer'
                  "
                ></i>
              </div>
            </div>
            <div v-if="branch.collapse_active">
              <div class="d-flex flex-row mb-3">
                <div
                  style="
                    font-size: 14px;
                    padding: 0px;
                    padding-top: 10px;
                    padding-bottom: 10px;
                  "
                  class="tab-items"
                  @click.prevent="chnageInnerTabBranch(tabs)"
                  :style="
                    selected_branch_inner_tab.name == tabs.name
                      ? 'color: black;'
                      : 'color: rgb(120 120 120);'
                  "
                  :class="
                    selected_branch_inner_tab.name == tabs.name
                      ? 'tab-items-active'
                      : ''
                  "
                  v-for="(tabs, tabs_index) in branch_inner_tabs"
                >
                  {{ tabs.name }}
                </div>
              </div>
              <div class="p-3">
                <div
                  class="d-flex flex-column"
                  v-if="selected_branch_inner_tab.name == 'Others'"
                >
                  <div class="card sub-category-form">
                    <div
                      class="d-flex flex-row-reverse justify-content-between align-items-center py-2"
                    >
                      <b-form-radio-group
                        id="btn-radios-2"
                        v-model="other_setting_data.store_open_close"
                        :options="store_open_close_type"
                        :button-variant="
                          other_setting_data.store_open_close == true
                            ? 'outline-success'
                            : 'outline-danger'
                        "
                        size="sm"
                        name="radio-btn-outline"
                        buttons
                      ></b-form-radio-group>
                      <span
                        class="text-heading"
                        style="
                          font-size: 25px !important;
                          padding-left: 0px !important;
                          font-weight: 500 !important;
                        "
                        >Other settings</span
                      >
                    </div>
                    <div class="d-flex flex-column">
                      <div
                        class="d-flex flex-column py-2"
                        style="justify-content: space-between"
                      >
                        <div
                          class="d-flex flex-row"
                          style="width: 100% !important"
                        >
                          <b-form-checkbox
                            switch
                            v-model="branch_other_settings_data.free_delivery"
                          >
                            <span
                              class="text-heading"
                              style="
                                font-size: 16px !important;
                                padding-left: 0px !important;
                                font-weight: 500 !important;
                              "
                              >Free Delivery Available</span
                            >
                          </b-form-checkbox>
                        </div>
                        <span
                          class="text-heading"
                          style="
                            width: 100% !important;
                            padding-left: 0px !important;
                            font-size: 12px !important;
                            padding-left: 0px !important;
                            font-weight: 300 !important;
                          "
                          >Free delivery if amount is more than</span
                        >
                        <b-form-input
                          v-model="
                            branch_other_settings_data.free_delivery_if_more
                          "
                          style="
                            width: 100% !important;
                            margin-top: -6px !important;
                          "
                          type="text"
                          placeholder="₹ 000"
                        />
                      </div>
                      <div
                        class="d-flex flex-column py-4"
                        style="justify-content: space-between"
                      >
                        <div
                          class="d-flex flex-row"
                          style="width: 100% !important"
                        >
                          <b-form-checkbox
                            switch
                            v-model="branch_other_settings_data.exchange"
                            ><span
                              class="text-heading"
                              style="
                                font-size: 16px !important;
                                padding-left: 0px !important;
                                font-weight: 500 !important;
                              "
                              >Exchange Available</span
                            ></b-form-checkbox
                          >
                        </div>
                        <div
                          class="d-flex flex-column"
                          style="width: 100% !important"
                        >
                          <span
                            class="text-heading"
                            style="
                              width: 100% !important;
                              padding-left: 0px !important;
                              font-size: 12px !important;
                              padding-left: 0px !important;
                              font-weight: 300 !important;
                            "
                            >Exchange Policy</span
                          >
                          <div class="d-flex flex-row align-items-center mb-2">
                            <b-form-textarea
                              v-model="branch_other_settings_data.policies"
                              placeholder="Exchange Policies"
                              rows="3"
                              no-resize
                            ></b-form-textarea>
                          </div>
                        </div>
                      </div>
                      <div
                        class="d-flex flex-column mb-4"
                        style="justify-content: space-between"
                      >
                        <span
                          class="text-heading"
                          style="
                            width: 100% !important;
                            font-size: 16px !important;
                            padding-left: 0px !important;
                            font-weight: 500 !important;
                            margin-top: -20px;
                            margin-bottom: 10px;
                          "
                          >Packing Charges</span
                        >
                        <b-form-input
                          v-model="branch_other_settings_data.packing_charges"
                          style="
                            width: 100% !important;
                            margin-top: -6px !important;
                          "
                          type="text"
                          placeholder="₹ 000"
                        />
                      </div>
                      <div
                        class="d-flex flex-column mb-4"
                        style="justify-content: space-between"
                      >
                        <div
                          class="d-flex flex-row"
                          style="width: 100% !important"
                        >
                          <b-form-checkbox
                            switch
                            v-model="branch_other_settings_data.negociation"
                            ><span
                              class="text-heading"
                              style="
                                font-size: 16px !important;
                                padding-left: 0px !important;
                                font-weight: 500 !important;
                              "
                              >Negociation Available</span
                            ></b-form-checkbox
                          >
                        </div>
                      </div>
                      <div class="d-flex flex-row justify-content-center">
                        <button
                          class="button"
                          @click.prevent="saveBranchOtherData"
                        >
                          <i class="fa fa-save mr-2"></i> Save
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
                <div
                  class="d-flex flex-column"
                  v-if="selected_branch_inner_tab.name == 'Delivery Price'"
                >
                  <div class="card sub-category-form">
                    <div
                      style="width: 100% !important"
                      class="mb-2 d-flex flex-row align-items-center justify-content-between"
                    >
                      <span
                        class="heading"
                        style="font-size: 20px; background: none; border: none"
                        >Store Delivery</span
                      >
                      <span class="text-heading"
                        >Service Radius: {{ branch_service_radius }}</span
                      >
                      <!-- <div class="d-flex flex-row">
                                                <b-form-select style="width: 20% !important" placeholder="Service Radius" disabled v-model="store_service_radius" :options="store_service_radius_option"></b-form-select>
                                            </div> -->
                    </div>
                    <div class="d-flex flex-column" style="gap: 10px">
                      <div
                        class="d-flex flex-row"
                        style="gap: 10px"
                        v-for="(del, del_index) in branch_delivery_form"
                      >
                        <span
                          style="
                            width: 20% !important;
                            max-width: 20% !important;
                            min-height: 20% !important;
                          "
                          class="text-heading"
                          >{{ `${del.km} KM` }}</span
                        >
                        <b-form-input
                          style="width: 40% !important"
                          v-model="del.time"
                          placeholder="Time in minute"
                        ></b-form-input>
                        <b-form-input
                          style="width: 40% !important"
                          v-model="del.price"
                          placeholder="Price"
                        ></b-form-input>
                      </div>
                    </div>
                    <div class="d-flex flex-row justify-content-center pt-3">
                      <button
                        class="button"
                        @click.prevent="saveBranchDeliveryPriceDetails"
                      >
                        <i class="fa fa-save mr-2"></i> Save Branch Delivery
                        Details
                      </button>
                    </div>
                  </div>
                </div>
                <div
                  class="d-flex flex-column"
                  v-if="selected_branch_inner_tab.name == 'Branch Image'"
                >
                  <div class="card sub-category-form">
                    <div
                      style="width: 100% !important"
                      class="mb-2 d-flex flex-row align-items-center"
                    >
                      <span
                        class="text-heading"
                        style="font-size: 20px; background: none; border: none"
                        >Branch Image ({{ selectedBranch.branch_name }})</span
                      >
                    </div>
                    <div
                      class="d-flex flex-row align-items-center"
                    >
                      <b-form-file
                        @input="changeBranchImage($event)"
                        v-model="branch_image"
                      ></b-form-file>
                      <div
                        class="d-flex flex-column px-3"
                        v-if="branch_image_url"
                      >
                        <img
                          style="width: 100px; border-radius: 16px"
                          :src="branch_image_url"
                          alt="Image"
                        />
                      </div>
                    </div>
                    <div class="d-flex flex-row justify-content-center pt-3">
                      <button class="button" @click.prevent="saveBranchImage">
                        <i class="fa fa-save mr-2"></i> Save Branch Image
                      </button>
                    </div>
                  </div>
                </div>
                <div
                  class="d-flex flex-column"
                  v-if="selected_branch_inner_tab.name == 'Branch Timings'"
                >
                  <div class="card sub-category-form">
                    <div
                      style="width: 100% !important"
                      class="mb-2 d-flex flex-row align-items-center"
                    >
                      <span
                        class="text-heading"
                        style="font-size: 20px; background: none; border: none"
                        >Branch Timings ({{ selectedBranch.branch_name }})</span
                      >
                    </div>
                    <div class="d-flex flex-column" style="gap: 5px">
                      <div
                        class="d-flex flex-row align-items-center"
                        style="gap: 5px"
                        v-for="(days, days_index) in branchTimings"
                      >
                        <div style="width: 26% !important">
                          <span class="text-heading">{{ days.day }}</span>
                        </div>
                        <div style="width: 30% !important">
                          <b-form-timepicker
                            :disabled="!days.is_open"
                            v-model="days.open_time"
                            placeholder="time"
                            locale="en"
                          ></b-form-timepicker>
                        </div>
                        <div style="width: 30% !important">
                          <b-form-timepicker
                            :disabled="!days.is_open"
                            v-model="days.close_time"
                            placeholder="time"
                            locale="en"
                          ></b-form-timepicker>
                        </div>
                        <div style="width: 24% !important">
                          <b-form-select
                            v-model="days.is_open"
                            :options="store_status_options"
                          ></b-form-select>
                        </div>
                      </div>
                    </div>
                    <div class="d-flex flex-row justify-content-center pt-3">
                      <button
                        class="button"
                        @click.prevent="saveStoreBranchTimings"
                      >
                        <i class="fa fa-save mr-2"></i> Save Branch Timings
                      </button>
                    </div>
                  </div>
                </div>
                <div
                  class="d-flex flex-column gap15"
                  v-if="selected_branch_inner_tab.name == 'Products'"
                >
                  <div
                    class="card sub-category-form d-flex flex-row align-items-center justify-content-between"
                    style="border-radius: 16px"
                    v-for="(
                      product, branch_product_index
                    ) in branch_product_list"
                    :key="branch_product_index"
                  >
                    <div class="d-flex flex-row align-items-center p-2">
                      <img
                        style="
                          border-radius: 16px;
                          height: 60px !important;
                          width: 100px !important;
                          object-fit: cover;
                        "
                        :src="
                          product.product.images_of_products.length
                            ? product.product.images_of_products[0].image_url
                            : ''
                        "
                        alt="Image"
                      />
                      <div class="d-flex flex-column">
                        <span class="text-heading">{{
                          product.product.name
                        }}</span>
                        <span style="margin-top: -15px" class="text-heading"
                          >Price: {{ product.product.price }}</span
                        >
                      </div>
                    </div>
                    <span class="d-flex flex-row align-items-center">
                      <span class="text-heading" style="padding-left: 0px"
                        >Active/Inactive</span
                      ><b-form-checkbox
                        v-model="product.active"
                        switch
                      ></b-form-checkbox>
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="card sub-category-form"
            v-if="!open_settings && branch_list.length == 0"
          >
            <div class="d-flex flex-row justify-content-center">
              <span class="text-heading" style="font-size: 20px !important"
                >No Branches</span
              >
            </div>
          </div>
        </div>
        <div
          class="d-flex flex-column"
          style="
            width: 60% !important;
            gap: 10px;
            height: 100% !important;
            overflow-y: scroll;
          "
          v-else-if="open_form"
        >
          <div class="d-flex sub-category-form flex-column" style="gap: 10px">
            <div
              class="d-flex flex-row align-items-center justify-content-between"
            >
              <h1
                class="heading"
                style="
                  font-size: 16px;
                  width: 100% !important;
                  background: none;
                  border: none;
                  color: black;
                "
              >
                {{ edit_id ? "Edit Branch" : "Add Branch" }}
              </h1>
              <i
                @click.prevent="closeForm"
                style="font-size: 20px"
                class="fa fa-times-circle text-danger cursor-pointer"
                aria-hidden="true"
              ></i>
            </div>
            <div class="d-flex flex-column px-3">
              <b-form-group label="Branch Name" class="mb-0">
                <b-form-input
                  type="text"
                  v-model="create_branch_data.branch_name"
                  placeholder="Branch Name"
                />
              </b-form-group>
            </div>
            <div class="d-flex flex-column px-3">
              <b-form-group label="GST Number" class="mb-0">
                <b-form-input
                  type="text"
                  v-model="create_branch_data.gst_number"
                  placeholder="GST Number"
                />
              </b-form-group>
            </div>
            <div class="d-flex flex-column px-3">
              <b-form-group label="FSSAI Number" class="mb-0">
                <b-form-input
                  type="text"
                  v-model="create_branch_data.fssai_number"
                  placeholder="FSSAI Number"
                />
              </b-form-group>
            </div>
            <div class="d-flex flex-column px-3">
              <b-form-group label="Email" class="mb-0">
                <b-form-input
                  type="text"
                  v-model="create_branch_data.email"
                  placeholder="Email"
                />
              </b-form-group>
            </div>
            <div class="d-flex flex-column px-3">
              <b-form-group label="Password" class="mb-0">
                <b-form-input
                  type="text"
                  v-model="create_branch_data.password"
                  placeholder="Password"
                />
              </b-form-group>
            </div>
            <div class="d-flex flex-row">
              <div class="d-flex flex-column px-3 w50">
                <b-form-group label="Mobile" class="mb-0">
                  <b-form-input
                    type="text"
                    v-model="create_branch_data.mobile"
                    placeholder="Mobile"
                  />
                </b-form-group>
              </div>
              <div class="d-flex flex-column px-3 w50">
                <b-form-group label="Alt Mobile" class="mb-0">
                  <b-form-input
                    type="text"
                    v-model="create_branch_data.alt_mobile"
                    placeholder="Alt Mobile"
                  />
                </b-form-group>
              </div>
            </div>
            <div class="d-flex flex-column px-3">
              <b-form-group label="Address - 1" class="mb-0">
                <b-form-input
                  type="text"
                  v-model="create_branch_data.add1"
                  placeholder="Address - 1"
                />
              </b-form-group>
            </div>
            <div class="d-flex flex-column px-3">
              <b-form-group label="Address - 2" class="mb-0">
                <b-form-input
                  type="text"
                  v-model="create_branch_data.add2"
                  placeholder="Address - 2"
                />
              </b-form-group>
            </div>
            <div class="d-flex flex-column px-3">
              <b-form-group label="Area" class="mb-0">
                <b-form-input
                  type="text"
                  v-model="create_branch_data.area"
                  placeholder="Area"
                />
              </b-form-group>
            </div>
            <div class="d-flex flex-column px-3">
              <b-form-group label="Landmark" class="mb-0">
                <b-form-input
                  type="text"
                  v-model="create_branch_data.landmark"
                  placeholder="Landmark"
                />
              </b-form-group>
            </div>
            <div class="d-flex flex-row">
              <div class="d-flex flex-column px-3 w50">
                <b-form-group label="City" class="mb-0">
                  <b-form-input
                    type="text"
                    v-model="create_branch_data.city"
                    placeholder="City"
                  />
                </b-form-group>
              </div>
              <div class="d-flex flex-column px-3 w50">
                <b-form-group label="State" class="mb-0">
                  <b-form-input
                    type="text"
                    v-model="create_branch_data.state"
                    placeholder="State"
                  />
                </b-form-group>
              </div>
            </div>
            <div class="d-flex flex-row">
              <div class="d-flex flex-column px-3 w50">
                <b-form-group label="PIN" class="mb-0">
                  <b-form-input
                    type="text"
                    v-model="create_branch_data.pin"
                    placeholder="PIN"
                  />
                </b-form-group>
              </div>
              <div class="d-flex flex-column px-3 w50">
                <b-form-group label="Country" class="mb-0">
                  <b-form-input
                    type="text"
                    v-model="create_branch_data.country"
                    placeholder="Country"
                  />
                </b-form-group>
              </div>
            </div>
            <div class="d-flex flex-row">
              <div class="d-flex flex-column px-3 w50">
                <b-form-group label="Lattitude" class="mb-0">
                  <b-form-input
                    type="text"
                    v-model="create_branch_data.lat"
                    placeholder="Lattitude"
                  />
                </b-form-group>
              </div>
              <div class="d-flex flex-column px-3 w50">
                <b-form-group label="Longitude" class="mb-0">
                  <b-form-input
                    type="text"
                    v-model="create_branch_data.lng"
                    placeholder="Longitude"
                  />
                </b-form-group>
              </div>
            </div>
            <div class="d-flex flex-row align-items-center">
              <div class="d-flex flex-column px-3 w70">
                <b-form-group label="Branch Image" class="mb-0">
                  <b-form-file
                    @input="changeImage($event)"
                    v-model="create_branch_data.branch_image"
                    class="mb-2"
                  ></b-form-file>
                </b-form-group>
              </div>
              <div
                class="d-flex flex-column px-3"
                v-if="create_branch_data.branch_image_url"
              >
                <img
                  style="width: 100px; border-radius: 16px"
                  :src="create_branch_data.branch_image_url"
                  alt="Image"
                />
              </div>
            </div>
            <div class="d-flex flex-column px-3">
              <b-form-group label="Service Radius" class="mb-0">
                <b-form-input
                  disabled
                  type="number"
                  @change="
                    makeSelfDeliveryTimings(create_branch_data.service_radius)
                  "
                  v-model="create_branch_data.service_radius"
                  placeholder="Service Radius"
                />
              </b-form-group>
            </div>
            <div class="d-flex flex-column px-3">
              <b-form-group label="Delivery Types" class="mb-0">
                <vSelect
                  multiple
                  placeholder="Delivery Types"
                  v-model="create_branch_data.vendor_delivery_types"
                  :label="'type'"
                  :options="delivery_types"
                ></vSelect>
              </b-form-group>
            </div>
            <div
              class="d-flex sub-category-form flex-column px-3"
              style="gap: 5px"
              v-if="
                create_branch_data.vendor_delivery_types.find(
                  (e) => e.type == 'SELLER DELIVERY'
                ) && create_branch_data.self_delivery_timings.length
              "
            >
              <div
                class="d-flex flex-row w-100"
                style="gap: 5px"
                v-for="(
                  timing, timing_index
                ) in create_branch_data.self_delivery_timings"
                :key="timing_index"
              >
                <span
                  class="heading w-25"
                  style="
                    font-size: 16px;
                    width: 25% !important;
                    background: none;
                    border: none;
                    color: black;
                  "
                >
                  {{ timing.km }} Km
                </span>
                <div class="d-flex flex-row w-75" style="gap: 5px">
                  <b-form-input
                    class=""
                    v-model="timing.price"
                    placeholder="Price"
                  ></b-form-input>
                  <b-form-input
                    class=""
                    v-model="timing.time"
                    placeholder="Time"
                  ></b-form-input>
                </div>
              </div>
            </div>
            <div
              class="d-flex sub-category-form flex-column px-3"
              style="gap: 5px"
              v-if="
                create_branch_data.vendor_delivery_types.find(
                  (e) => e.type == 'SELLER DELIVERY'
                )
              "
            >
              <span
                class="text-heading"
                style="
                  font-size: 16px;
                  width: max-content !important;
                  background: none;
                  border: none;
                "
              >
                Vendor Delivery Partner Details ({{
                  create_branch_data.seller_delivery_partners.length
                }})</span
              >
              <div
                class="d-flex p-3 flex-column w-100"
                style="gap: 5px"
                v-for="(
                  sel_del_partner, sel_del_partner_index
                ) in create_branch_data.seller_delivery_partners"
                :key="sel_del_partner_index"
              >
                <div class="d-flex flex-row" style="gap: 5px">
                  <b-form-group label="First Name" class="mb-0">
                    <b-form-input
                      type="text"
                      v-model="
                        create_branch_data.seller_delivery_partners[
                          sel_del_partner_index
                        ].first_name
                      "
                      placeholder="First Name"
                    />
                  </b-form-group>
                  <b-form-group label="Last Name" class="mb-0">
                    <b-form-input
                      type="text"
                      v-model="
                        create_branch_data.seller_delivery_partners[
                          sel_del_partner_index
                        ].last_name
                      "
                      placeholder="Last Name"
                    />
                  </b-form-group>
                </div>
                <div class="d-flex flex-row" style="gap: 5px">
                  <b-form-group label="Username" class="mb-0">
                    <b-form-input
                      type="text"
                      v-model="
                        create_branch_data.seller_delivery_partners[
                          sel_del_partner_index
                        ].username
                      "
                      placeholder="Username"
                    />
                  </b-form-group>
                  <b-form-group label="Password" class="mb-0">
                    <b-form-input
                      type="text"
                      v-model="
                        create_branch_data.seller_delivery_partners[
                          sel_del_partner_index
                        ].password
                      "
                      placeholder="Password"
                    />
                  </b-form-group>
                </div>
                <div
                  class="d-flex flex-row justify-content-center my-2"
                  style="gap: 5px"
                >
                  <button class="button" @click.prevent="addAnother">
                    Add Another
                  </button>
                  <button
                    class="button"
                    @click.prevent="removeDelPartner(sel_del_partner_index)"
                    v-if="
                      create_branch_data.seller_delivery_partners.length > 1
                    "
                  >
                    Remove This
                  </button>
                </div>
              </div>
            </div>
            <div class="d-flex flex-row text-center justify-content-center">
              <div class="d-flex flex-row px-3">
                <b-form-group label="Is Open" class="mb-0">
                  <b-form-checkbox
                    v-model="create_branch_data.is_open"
                    size="lg"
                    switch
                  ></b-form-checkbox>
                </b-form-group>
              </div>
              <div class="d-flex flex-row px-3">
                <b-form-group label="Verified" class="mb-0">
                  <b-form-checkbox
                    v-model="create_branch_data.verified"
                    size="lg"
                    switch
                  ></b-form-checkbox>
                </b-form-group>
              </div>
              <div class="d-flex flex-row px-3">
                <b-form-group label="Approved" class="mb-0">
                  <b-form-checkbox
                    size="lg"
                    v-model="create_branch_data.approved"
                    switch
                  ></b-form-checkbox>
                </b-form-group>
              </div>
            </div>
            <div class="d-flex justify-content-center">
              <button
                class="button"
                @click.prevent="
                  !edit_id ? saveBranchDetails() : updateBranchDetails()
                "
              >
                {{ edit_id ? "Update" : "Create" }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import vSelect from "vue-select";
export default {
  components: { vSelect },
  data() {
    return {
      selected_tab: {
        name: "Store Image",
        icon: "fa fa-picture-o",
      },
      inner_tabs: [
        {
          name: "Store Image",
          icon: "fa fa-picture-o",
        },
        {
          name: "Store Timings",
          icon: "fa fa-clock-o",
        },
        {
          name: "Delivery Price",
          icon: "fa fa-truck",
        },
        {
          name: "Others",
          icon: "fa fa-cogs",
        },
      ],
      selected_branch_inner_tab: {
        name: "Products",
        // icon: 'fa fa-cogs'
      },
      branch_inner_tabs: [
        {
          name: "Products",
          // icon: 'fa fa-cogs'
        },
        {
          name: "Branch Image",
          // icon: 'fa fa-picture-o'
        },
        {
          name: "Branch Timings",
          // icon: 'fa fa-clock-o'
        },
        {
          name: "Delivery Price",
          // icon: 'fa fa-truck'
        },
        {
          name: "Others",
          // icon: 'fa fa-cogs'
        },
      ],
      store_open_close_type: [
        {
          value: true,
          text: "Open",
        },
        {
          value: false,
          text: "Closed",
        },
      ],
      other_setting_data: {
        store_open_close: true,
        free_delivery: false,
        free_delivery_if_more: null,
        exchange: false,
        policies: "",
        packing_charges: "",
        negociation: false,
      },
      open_settings: false,
      open_store_image_form: false,
      open_store_timings_form: false,
      open_store_delivery_form: false,
      open_other_settings_form: false,
      store_service_radius: null,
      store_service_radius_option: Array.from(Array(10).keys()).map(
        (e) => e + 1
      ),
      store_status_options: [
        {
          value: null,
          text: "Status",
        },
        {
          value: true,
          text: "Open",
        },
        {
          value: false,
          text: "Close",
        },
      ],
      store_delivery_form: [],
      store_timings_form: [],
      store_list: [],
      branch_list: [],
      vendor_delivery_types: [],
      delivery_types: [],
      loader: false,
      selected_store_index: null,
      selected_store: null,
      open_form: false,
      edit_id: null,
      store_image_url: null,
      store_image: null,
      self_delivery_timing_template: {
        km: null,
        time: null,
        price: null,
      },
      selectedBranch: null,
      branchTimings: [],
      OpenBranchTimings: false,
      branch_product_list: [],
      create_branch_data: {
        branch_name: null,
        gst_number: null,
        fssai_number: null,
        email: null,
        password: null,
        mobile: null,
        alt_mobile: null,
        add1: null,
        add2: null,
        area: null,
        landmark: null,
        city: null,
        state: null,
        is_open: true,
        approved: true,
        verified: true,
        pin: null,
        country: null,
        lat: null,
        lng: null,
        branch_image: null,
        branch_image_url: null,
        vendor_delivery_types: [],
        service_radius: 5,
        self_delivery_timings: [],
        seller_delivery_partners: [
          {
            first_name: null,
            last_name: null,
            username: null,
            password: null,
          },
        ],
      },
      selected_branch_index: null,
      branch_image: null,
      branch_image_url: null,
      branch_delivery_form: [],
      branch_service_radius: 5,
      branch_other_settings_data: {
        branch_open_close: true,
        free_delivery: false,
        free_delivery_if_more: null,
        exchange: false,
        policies: "",
        negociation: false,
        packing_charges: null,
      },
    };
  },
  props: ['searchText'],
  async mounted() {
    this.loader = true;
    await this.fetchStores();
    this.loader = false;
  },
  watch: {
    searchText(val) {
            clearTimeout(this.timer)
            this.timer = setTimeout(async () => {
                this.loader = true
                await this.fetchStores()
                this.loader = false
            }, 300);
        }
  },
  methods: {
    async saveBranchImage() {
      try {
        this.loader = true;
        const form = new FormData();
        form.append("vendor_id", this.selectedBranch.vendor_id);
        form.append("store_id", this.selectedBranch.store_id);
        form.append("branch_id", this.selectedBranch.id);
        form.append("image", this.branch_image);
        const response = await this.$axios.post("/upload-branch-image", form);
        this.$toast.show(response.data.message, {
          duration: 1500,
          position: "top-right",
          keepOnHover: true,
          type: response.data.status,
        });
        // await this.fetchStores()
        // await this.fetchStoreTimings()
        await this.fetchBranches();
        // this.closeForm()
        this.loader = false;
      } catch (error) {
        console.log(error);
      }
    },
    async chnageInnerTabBranch(tabs) {
      console.log("chnageInnerTabBranch");
      this.loader = true;
      this.selected_branch_inner_tab = tabs;
      switch (tabs.name) {
        case "Products":
          this.selectedBranch = this.branch_list[this.selected_branch_index];
          await this.fetchProductsForTheStores(
            this.selected_store.id,
            this.selected_store.vendor_id,
            this.branch_list[this.selected_branch_index].id
          );
          break;
        case "Branch Timings":
          this.selectedBranch = this.branch_list[this.selected_branch_index];
          await this.openStoreTimingDetails(
            this.branch_list[this.selected_branch_index],
            this.selected_branch_index
          );
          break;
        case "Branch Image":
          this.selectedBranch = this.branch_list[this.selected_branch_index];
          this.branch_image_url =
            this.branch_list[this.selected_branch_index].image_url;
          this.branch_image = null;
          break;
        case "Delivery Price":
          this.selectedBranch = this.branch_list[this.selected_branch_index];
          await this.fetchBranchDeliveryPriceDetails();
          break;
        case "Others":
          this.selectedBranch = this.branch_list[this.selected_branch_index];
          await this.fetchBranchOtherSettingData();
          break;
      }
      this.loader = false;
    },
    async changeTab(tab) {
      this.selected_tab = tab;
      switch (tab.name) {
        case "Store Image":
          await this.openStoreImageForm();
          break;
        case "Store Timings":
          await this.OpenStoreTimingsForm();
          break;
        case "Delivery Price":
          await this.OpenStoreDeliveryPriceForm();
          break;
        case "Others":
          await this.openOtherSettingForm();
          break;
      }
    },
    async saveBranchOtherData() {
      try {
        const data = {
          vendor_id: this.selectedBranch.vendor_id,
          branch_id: this.selectedBranch.id,
          store_id: this.selectedBranch.store_id,
          ...this.branch_other_settings_data,
        };
        const response = await this.$axios.post(
          "/upload-store-other-details",
          data
        );
        this.$toast.show(response.data.message, {
          duration: 1500,
          position: "top-right",
          keepOnHover: true,
          type: response.data.status,
        });
      } catch (error) {
        console.log(error);
      }
    },
    async fetchBranchOtherSettingData() {
      try {
        const response = await this.$axios.get(
          `/fetch-store-other-details?vendor_id=${this.selectedBranch.vendor_id}&store_id=${this.selectedBranch.store_id}&branch_id=${this.selectedBranch.id}`
        );
        if (response.data.code == 401) {
          await this.logout();
        }
        this.branch_other_settings_data = {
          store_open_close: Boolean(response.data.store.is_open),
          free_delivery: Boolean(response.data.store.free_delivery),
          free_delivery_if_more: response.data.store.free_delivery_if_more,
          exchange: Boolean(response.data.store.exchange),
          policies: response.data.store.policies,
          packing_charges: response.data.store.packing_charges,
          negociation: Boolean(response.data.store.negociation),
        };
      } catch (error) {
        console.log(error);
      }
    },
    async saveOtherData() {
      try {
        console.log(this.other_setting_data);
        const data = {
          vendor_id: this.selected_store.vendor_id,
          store_id: this.selected_store.id,
          ...this.other_setting_data,
          policies: this.other_setting_data.policies,
        };
        const response = await this.$axios.post(
          "/upload-store-other-details",
          data
        );
        this.$toast.show(response.data.message, {
          duration: 1500,
          position: "top-right",
          keepOnHover: true,
          type: response.data.status,
        });
      } catch (error) {
        console.log(error);
      }
    },
    add_policy() {
      this.other_setting_data.policies.push({
        text: null,
      });
    },
    remove_policy(index) {
      this.other_setting_data.policies.splice(index, 1);
    },
    async openSettings() {
      this.open_settings = !this.open_settings;
      if (this.open_settings) {
        this.selected_tab = this.inner_tabs[0];
        await this.changeTab(this.selected_tab);
      }
    },
    async openOtherSettingForm() {
      this.loader = true;
      await this.fetchOtherSettingData();
      this.open_other_settings_form = true;
      this.open_store_image_form = false;
      this.open_store_delivery_form = false;
      this.open_store_timings_form = false;
      this.loader = false;
    },
    async fetchOtherSettingData() {
      try {
        const response = await this.$axios.get(
          `/fetch-store-other-details?vendor_id=${this.selected_store.vendor_id}&store_id=${this.selected_store.id}`
        );
        if (response.data.code == 401) {
          await this.logout();
        }
        this.other_setting_data = {
          store_open_close: Boolean(response.data.store.is_open),
          free_delivery: Boolean(response.data.store.free_delivery),
          free_delivery_if_more: response.data.store.free_delivery_if_more,
          exchange: Boolean(response.data.store.exchange),
          policies: response.data.store.policies,
          packing_charges: response.data.store.packing_charges,
          negociation: Boolean(response.data.store.negociation),
        };
      } catch (error) {
        console.log(error);
      }
    },
    async openStoreImageForm() {
      this.loader = true;
      this.open_store_image_form = true;
      this.open_store_delivery_form = false;
      this.open_store_timings_form = false;
      this.open_other_settings_form = false;
      this.loader = false;
    },
    async OpenStoreDeliveryPriceForm() {
      this.loader = true;
      await this.fetchStoreDeliveryPriceDetails();
      this.open_store_delivery_form = true;
      this.open_store_image_form = false;
      this.open_store_timings_form = false;
      this.open_other_settings_form = false;
      this.loader = false;
    },
    async OpenStoreTimingsForm() {
      this.loader = true;
      await this.fetchStoreTimings();
      this.open_store_timings_form = true;
      this.open_store_image_form = false;
      this.open_store_delivery_form = false;
      this.open_other_settings_form = false;
      this.loader = false;
    },
    async fetchStoreDeliveryPriceDetails() {
      try {
        const response = await this.$axios.get(
          `/fetch-vendor-delivery-price?vendor_id=${this.selected_store.vendor_id}&store_id=${this.selected_store.id}`
        );
        if (response.data.code == 401) {
          await this.logout();
        }
        if (response.data.delivery_details.length) {
          this.store_delivery_form = response.data.delivery_details.map((e) => {
            return {
              km: e.km,
              time: e.time,
              price: e.price,
            };
          });
        } else {
          this.store_delivery_form = Array.from(
            Array(this.store_service_radius).keys()
          ).map((e) => {
            return {
              km: e + 1,
              time: null,
              price: null,
            };
          });
        }
      } catch (error) {
        console.log(error);
      }
    },
    async fetchBranchDeliveryPriceDetails() {
      try {
        const response = await this.$axios.get(
          `/fetch-vendor-delivery-price?vendor_id=${this.selectedBranch.vendor_id}&store_id=${this.selectedBranch.store_id}&branch_id=${this.selectedBranch.id}`
        );
        if (response.data.code == 401) {
          await this.logout();
        }
        if (response.data.delivery_details.length) {
          this.branch_delivery_form = response.data.delivery_details.map(
            (e) => {
              return {
                km: e.km,
                time: e.time,
                price: e.price,
              };
            }
          );
        } else {
          this.branch_delivery_form = Array.from(
            Array(this.store_service_radius).keys()
          ).map((e) => {
            return {
              km: e + 1,
              time: null,
              price: null,
            };
          });
        }
      } catch (error) {
        console.log(error);
      }
    },
    async saveStoreDeliveryPriceDetails() {
      try {
        this.loader = true;
        const response = await this.$axios.post("/save-vendor-delivery-price", {
          vendor_id: this.selected_store.vendor_id,
          store_id: this.selected_store.id,
          delivery_data: this.store_delivery_form,
        });
        this.$toast.show(response.data.message, {
          duration: 1500,
          position: "top-right",
          keepOnHover: true,
          type: response.data.status,
        });
        await this.fetchStores();
        this.loader = false;
      } catch (error) {
        console.log(error);
      }
    },
    async saveBranchDeliveryPriceDetails() {
      try {
        this.loader = true;
        const response = await this.$axios.post("/save-vendor-delivery-price", {
          vendor_id: this.selectedBranch.vendor_id,
          store_id: this.selectedBranch.store_id,
          branch_id: this.selectedBranch.id,
          delivery_data: this.branch_delivery_form,
        });
        this.$toast.show(response.data.message, {
          duration: 1500,
          position: "top-right",
          keepOnHover: true,
          type: response.data.status,
        });
        await this.fetchStores();
        this.loader = false;
      } catch (error) {
        console.log(error);
      }
    },
    async openStoreTimingDetails(data, index) {
      this.loader = true;
      this.selectedBranch = data;
      this.selected_branch_index = index;
      await this.fetchBranchTimings();
      this.loader = false;
    },
    closeBranchDetails(index) {
      this.loader = true;
      this.branch_list[index].collapse_active = false;
      this.loader = false;
    },
    async openBranchDetails(data, index) {
      this.loader = true;
      this.OpenBranchTimings = false;
      if (
        this.selected_branch_index != null &&
        index == this.selected_branch_index
      ) {
        this.branch_product_list = [];
        this.branch_list[this.selected_branch_index].collapse_active = false;
        this.selected_branch_index = null;
      } else if (this.selected_branch_index != null) {
        this.branch_list[this.selected_branch_index].collapse_active = false;
        this.selected_branch_index = index;
        this.branch_list[this.selected_branch_index].collapse_active = true;
        this.chnageInnerTabBranch(this.branch_inner_tabs[0]);
      } else {
        this.selected_branch_index = index;
        this.branch_list[this.selected_branch_index].collapse_active = true;
        this.chnageInnerTabBranch(this.branch_inner_tabs[0]);
      }
      this.loader = false;
    },
    async logout() {
      await this.$auth.logout();
      this.$router.push("/login");
    },
    async saveBranchDetails() {
      this.loader = true;
      if (
        !this.create_branch_data.vendor_delivery_types.find(
          (e) => e.type == "SELLER DELIVERY"
        )
      ) {
        delete this.create_branch_data.seller_delivery_partners;
        delete this.create_branch_data.self_delivery_timings;
      }
      const keys = Object.keys(this.create_branch_data);
      const formData = new FormData();
      keys.forEach((key) => {
        if (key != "branch_image_url") {
          formData.append(
            key,
            Array.isArray(this.create_branch_data[key])
              ? JSON.stringify(this.create_branch_data[key])
              : this.create_branch_data[key]
          );
        }
      });
      formData.append("vendor_id", this.selected_store.vendor_id);
      formData.append("store_id", this.selected_store.id);
      const response = await this.$axios.post("/create-new-branche", formData);
      this.$toast.show(response.data.message, {
        duration: 1500,
        position: "top-right",
        keepOnHover: true,
        type: response.data.status,
      });
      await this.fetchBranches();
      this.closeForm();
      this.loader = false;
    },
    addAnother() {
      this.create_branch_data.seller_delivery_partners.push({
        first_name: null,
        last_name: null,
        username: null,
        password: null,
      });
    },
    removeDelPartner(index) {
      this.create_branch_data.seller_delivery_partners.splice(index, 1);
    },
    makeSelfDeliveryTimings(num) {
      const array = Array.from(Array(parseInt(num)).keys()).map((e) => e + 1);
      this.create_branch_data.self_delivery_timings = array.map((e) => {
        return {
          ...this.self_delivery_timing_template,
          km: e,
        };
      });
    },
    closeForm() {
      this.open_form = false;
      this.create_branch_data = {
        branch_name: null,
        gst_number: null,
        fssai_number: null,
        email: null,
        password: null,
        mobile: null,
        alt_mobile: null,
        add1: null,
        add2: null,
        area: null,
        landmark: null,
        city: null,
        state: null,
        is_open: true,
        approved: true,
        verified: true,
        pin: null,
        country: null,
        lat: null,
        lng: null,
        branch_image: null,
        branch_image_url: null,
        vendor_delivery_types: [],
        service_radius: 5,
        self_delivery_timings: [],
        seller_delivery_partners: [
          {
            first_name: null,
            last_name: null,
            username: null,
            password: null,
          },
        ],
      };
    },
    async changeStoreImage(event) {
      this.store_image_url = URL.createObjectURL(event);
    },
    async changeBranchImage(event) {
      console.log(event);
      this.branch_image_url = URL.createObjectURL(event);
    },
    async fetchStoreTimings() {
      try {
        const response = await this.$axios.get(
          `/fetch-store-timings?vendor_id=${this.selected_store.vendor_id}&store_id=${this.selected_store.id}`
        );
        if (response.data.code == 401) {
          await this.logout();
        }
        if (response.data.store_timings.length) {
          this.store_timings_form = response.data.store_timings.map((e) => {
            return {
              day: e.day,
              open_time: e.open_time,
              close_time: e.close_time,
              is_open: Boolean(e.is_open),
            };
          });
        } else {
          this.store_timings_form = [
            {
              day: "MONDAY",
              open_time: "09:00:00",
              close_time: "09:00:00",
              is_open: true,
            },
            {
              day: "TUESDAY",
              open_time: "09:00:00",
              close_time: "09:00:00",
              is_open: true,
            },
            {
              day: "WEDNESDAY",
              open_time: "09:00:00",
              close_time: "09:00:00",
              is_open: true,
            },
            {
              day: "THURSDAY",
              open_time: "09:00:00",
              close_time: "09:00:00",
              is_open: true,
            },
            {
              day: "FRIDAY",
              open_time: "09:00:00",
              close_time: "09:00:00",
              is_open: true,
            },
            {
              day: "SATURDAY",
              open_time: "09:00:00",
              close_time: "09:00:00",
              is_open: true,
            },
            {
              day: "SUNDAY",
              open_time: "09:00:00",
              close_time: "09:00:00",
              is_open: true,
            },
          ];
        }
      } catch (error) {
        console.log(error);
      }
    },
    async fetchBranchTimings() {
      try {
        const response = await this.$axios.get(
          `/fetch-store-timings?vendor_id=${this.selected_store.vendor_id}&store_id=${this.selected_store.id}&branch_id=${this.selectedBranch.id}`
        );
        if (response.data.code == 401) {
          await this.logout();
        }
        if (response.data.store_timings.length) {
          this.branchTimings = response.data.store_timings.map((e) => {
            return {
              day: e.day,
              open_time: e.open_time,
              close_time: e.close_time,
              is_open: Boolean(e.is_open),
            };
          });
        } else {
          this.branchTimings = [
            {
              day: "MONDAY",
              open_time: "09:00:00",
              close_time: "09:00:00",
              is_open: true,
            },
            {
              day: "TUESDAY",
              open_time: "09:00:00",
              close_time: "09:00:00",
              is_open: true,
            },
            {
              day: "WEDNESDAY",
              open_time: "09:00:00",
              close_time: "09:00:00",
              is_open: true,
            },
            {
              day: "THURSDAY",
              open_time: "09:00:00",
              close_time: "09:00:00",
              is_open: true,
            },
            {
              day: "FRIDAY",
              open_time: "09:00:00",
              close_time: "09:00:00",
              is_open: true,
            },
            {
              day: "SATURDAY",
              open_time: "09:00:00",
              close_time: "09:00:00",
              is_open: true,
            },
            {
              day: "SUNDAY",
              open_time: "09:00:00",
              close_time: "09:00:00",
              is_open: true,
            },
          ];
        }
      } catch (error) {
        console.log(error);
      }
    },
    async saveStoreTimings() {
      try {
        this.loader = true;
        const response = await this.$axios.post("/save-store-timings", {
          vendor_id: this.selected_store.vendor_id,
          store_id: this.selected_store.id,
          timings_data: this.store_timings_form,
        });
        this.$toast.show(response.data.message, {
          duration: 1500,
          position: "top-right",
          keepOnHover: true,
          type: response.data.status,
        });
        await this.fetchStores();
        this.loader = false;
      } catch (error) {
        console.log(error);
      }
    },
    async saveStoreBranchTimings() {
      try {
        this.loader = true;
        const response = await this.$axios.post("/save-store-timings", {
          vendor_id: this.selected_store.vendor_id,
          store_id: this.selected_store.id,
          branch_id: this.selectedBranch.id,
          timings_data: this.branchTimings,
        });
        this.$toast.show(response.data.message, {
          duration: 1500,
          position: "top-right",
          keepOnHover: true,
          type: response.data.status,
        });
        await this.fetchStores();
        this.loader = false;
      } catch (error) {
        console.log(error);
      }
    },
    async saveStoreImage() {
      try {
        this.loader = true;
        const form = new FormData();
        form.append("vendor_id", this.selected_store.vendor_id);
        form.append("store_id", this.selected_store.id);
        form.append("store_image", this.store_image);
        const response = await this.$axios.post("/upload-store-image", form);
        this.$toast.show(response.data.message, {
          duration: 1500,
          position: "top-right",
          keepOnHover: true,
          type: response.data.status,
        });
        await this.fetchStores();
        await this.fetchStoreTimings();
        // await this.fetchBranches()
        // this.closeForm()
        this.loader = false;
      } catch (error) {
        console.log(error);
      }
    },
    async changeImage(event) {
      this.create_branch_data.branch_image_url = URL.createObjectURL(event);
    },
    async openCreateForm() {
      this.loader = true;
      this.open_form = true;
      await this.fetchDeliveryTypes();
      await this.fetchDeliveryTypesForVendor();
      this.makeSelfDeliveryTimings(5);
      this.loader = false;
    },
    async showStoreForIndex(store_index) {
      this.loader = true;
      this.selected_store_index = store_index;
      this.selected_store = this.store_list[this.selected_store_index];
      this.store_image_url = this.selected_store.store_image_url;
      this.store_service_radius = this.selected_store.service_radius;
      await this.fetchBranches();
      await this.fetchDeliveryTypesForVendor();
      this.closeForm();
      this.loader = false;
    },
    async fetchStores() {
      try {
        let path = "/fetch-all-stores"
        if (this.searchText) {
          path = path + `?q=${this.searchText}`
        }
        const response = await this.$axios.get(path);
        if (response.data.code == 401) {
          await this.logout();
        }
        this.store_list = response.data.stores;
      } catch (error) {
        console.log(error);
      }
    },
    async fetchBranches() {
      try {
        let api_path = `/fetch-branches?vendor_id=${this.selected_store?.vendor?.id}&store_id=${this.selected_store.id}`;
        const response = await this.$axios.get(api_path);
        if (response.data.code == 401) {
          await this.logout();
        }
        if (response.data.code == 200) {
          this.branch_list = response.data.branches.map((e) => {
            return {
              ...e,
              collapse_active: false,
              branch_timings: false,
            };
          });
        } else {
          this.branch_list = [];
        }
      } catch (error) {
        console.log(error);
        this.branch_list = [];
      }
    },
    async fetchDeliveryTypes() {
      try {
        const response = await this.$axios.get("/get-delivery-types");
        if (response.data.code == 401) {
          await this.logout();
        }
        this.delivery_types = response.data.delivery_types;
      } catch (error) {
        console.log(error);
      }
    },
    async fetchDeliveryTypesForVendor() {
      try {
        const response = await this.$axios.get(
          `/get-vendor-delivery-types?vendor_id=${this.selected_store?.vendor?.id}`
        );
        if (response.data.code == 401) {
          await this.logout();
        }
        this.vendor_delivery_types = response.data.delivery_types;
        this.create_branch_data.vendor_delivery_types =
          this.vendor_delivery_types;
      } catch (error) {
        console.log(error);
      }
    },
    async fetchProductsForTheStores(store, vendor, branch) {
      let path = `/fetch-all-products-for-branch?vendor_id=${vendor}&store_id=${store}&branch_id=${branch}`;
      const response = await this.$axios.get(path);
      if (response.data.code == 401) {
        await this.logout();
      }
      this.branch_product_list = response.data.products.map((e) => {
        return {
          ...e,
          active: Boolean(e.active),
        };
      });
    },
  },
};
</script>
