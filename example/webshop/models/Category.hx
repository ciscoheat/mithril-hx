package webshop.models;

import mithril.M;
using StringTools;

class Category
{
    public var id : String;
    public var name : String;
    public var products : Array<Product>;

    public function new(?data, ?products) {
        if(data != null)
            this.name = data.name;

        if(products != null)
            this.products = products;
    }

    public function slug() {
        return name.replace(" ", "-").toLowerCase();
    }

    ///// Data access /////

    public static function all() : Promise<Array<Category>, String> {
        // Simulate a short delay, but every once in a while a long delay.
        var delay = Std.random(100);
        if(Math.random() > 0.87) delay = 2000;

        var mapData = function(data : Array<Dynamic>) {
            return data.map(function(d) {
                var products = d.products.map(function(p) return new Product(p));
                var c = new Category(d, products);
                for(p in products) p.category = c;
                return c;
            });
        };

        var def = M.deferred();
        haxe.Timer.delay(function() def.resolve(data()), delay);

        return def.promise.then(mapData);

        // See http://beta.json-generator.com/A0FlQeQ for content
        // (and a great site for generating JSON-data)

        /*
        var request = M.request({
            method: "GET",
            url: 'http://beta.json-generator.com/api/json/get/A0FlQeQ?delay=$delay',
            background: true,
            initialValue: [],
        }).then(mapData);
        */
    }

    static function data() {
        return [
            {
                "id": "7e778794-1e21-492a-82c0-63ac0adcb9b5",
                "name": "Morriston",
                "products": [
                    {
                        "id": "aeca7d5b-c854-412d-acc2-8e6e6149419a",
                        "name": "In",
                        "price": 129,
                        "stock": 7
                    },
                    {
                        "id": "cd798c91-7b06-4797-8ee3-9e30712159d5",
                        "name": "Ex laboris reprehenderit veniam",
                        "price": 407,
                        "stock": 0
                    },
                    {
                        "id": "75166f69-32a5-4c49-b7c2-8c8e427d2fb0",
                        "name": "Aliquip cupidatat qui",
                        "price": 505,
                        "stock": 21
                    },
                    {
                        "id": "85f91501-9f58-47e1-ac31-55b43068beac",
                        "name": "Eu tempor",
                        "price": 544,
                        "stock": 13
                    },
                    {
                        "id": "d4cc61e2-a1d7-4ee4-bd97-bd84f24431cf",
                        "name": "Non aute",
                        "price": 669,
                        "stock": 19
                    },
                    {
                        "id": "502b3df9-da67-44b3-987a-63ca9c47c405",
                        "name": "Irure",
                        "price": 133,
                        "stock": 20
                    },
                    {
                        "id": "4d8d4c55-2fab-455f-adb2-ed7565a2ccc4",
                        "name": "Consequat anim",
                        "price": 776,
                        "stock": 9
                    }
                ]
            },
            {
                "id": "784f137b-d56a-4ea8-a442-05aa41d8de81",
                "name": "Charco",
                "products": [
                    {
                        "id": "3859bc43-66f4-4a5a-94ef-c05b699e750f",
                        "name": "Eiusmod et",
                        "price": 634,
                        "stock": 20
                    },
                    {
                        "id": "6aff4125-1209-43af-a991-9d153417f95c",
                        "name": "Ex consequat",
                        "price": 700,
                        "stock": 6
                    },
                    {
                        "id": "9f12b8a6-36b7-4bed-bc62-8cecd23434ea",
                        "name": "Aliqua",
                        "price": 486,
                        "stock": 13
                    },
                    {
                        "id": "d4e2975f-f90a-4510-bf9a-4783c0b4c79a",
                        "name": "Culpa sunt aliquip ipsum",
                        "price": 81,
                        "stock": 9
                    },
                    {
                        "id": "a6be9192-ecbe-4bc8-898c-15c22aac3b2d",
                        "name": "Minim ipsum excepteur",
                        "price": 690,
                        "stock": 15
                    },
                    {
                        "id": "c0dec222-7ee4-4bf4-a816-0f6eef464a84",
                        "name": "Nisi",
                        "price": 788,
                        "stock": 5
                    },
                    {
                        "id": "a568c771-3049-4c90-8f30-02d933a05ed4",
                        "name": "Anim sunt",
                        "price": 208,
                        "stock": 3
                    },
                    {
                        "id": "937ce3ea-0af1-423a-8fd4-7902ed8e0b7d",
                        "name": "Nisi et ea esse",
                        "price": 662,
                        "stock": 13
                    },
                    {
                        "id": "1dd52d85-b1d5-4bf8-a0da-b5779045915d",
                        "name": "Sit nulla velit eu",
                        "price": 56,
                        "stock": 0
                    },
                    {
                        "id": "ced7bf71-47f5-44d7-a581-19685baed67e",
                        "name": "Ad",
                        "price": 742,
                        "stock": 22
                    },
                    {
                        "id": "9af9995b-f493-4f2c-a039-c812fa2a18c8",
                        "name": "Enim",
                        "price": 287,
                        "stock": 16
                    },
                    {
                        "id": "a73ea945-8919-4cde-b483-a1c4ce7ab38d",
                        "name": "Id adipisicing",
                        "price": 320,
                        "stock": 3
                    },
                    {
                        "id": "c836478a-6716-4e1d-9ba0-c069b3d057be",
                        "name": "Eu excepteur",
                        "price": 545,
                        "stock": 15
                    },
                    {
                        "id": "fb21236f-afea-4691-8dda-123a49877909",
                        "name": "Est ipsum",
                        "price": 93,
                        "stock": 11
                    }
                ]
            },
            {
                "id": "c02e8162-9ed2-4ba6-aa4d-db7caa25cb7a",
                "name": "Rushford",
                "products": [
                    {
                        "id": "65fe31aa-c00c-4412-b01b-5660b0192ef6",
                        "name": "Sit",
                        "price": 279,
                        "stock": 17
                    },
                    {
                        "id": "de3232f5-2cf1-40ea-b145-78fee43359ee",
                        "name": "Proident ut nostrud reprehenderit",
                        "price": 769,
                        "stock": 11
                    },
                    {
                        "id": "0b9e9792-500a-4331-a128-71ef20134d67",
                        "name": "Excepteur",
                        "price": 707,
                        "stock": 3
                    },
                    {
                        "id": "daba8379-baa0-40f6-b0d0-2d1f9dd9d781",
                        "name": "Lorem excepteur magna",
                        "price": 397,
                        "stock": 6
                    },
                    {
                        "id": "6387c47a-4fae-4737-95c8-f20df2245b3b",
                        "name": "Eiusmod",
                        "price": 477,
                        "stock": 29
                    },
                    {
                        "id": "11d2b2b8-66ba-4e5d-9378-6c2451774bd5",
                        "name": "Consectetur anim tempor reprehenderit",
                        "price": 384,
                        "stock": 16
                    },
                    {
                        "id": "ceaed769-7de3-40e2-9d4a-34d3d69b6295",
                        "name": "Consectetur officia",
                        "price": 36,
                        "stock": 27
                    },
                    {
                        "id": "053c27dd-6596-4b5c-815a-8f38fc00944a",
                        "name": "Mollit pariatur",
                        "price": 66,
                        "stock": 30
                    },
                    {
                        "id": "3badedaa-354d-46e4-a59b-c1b308a5ea70",
                        "name": "Cillum tempor fugiat",
                        "price": 503,
                        "stock": 24
                    },
                    {
                        "id": "11d9e54c-160a-44c4-88be-bc310bd9d0b6",
                        "name": "Ullamco",
                        "price": 626,
                        "stock": 1
                    },
                    {
                        "id": "0a1b3fa4-3a7f-4e3a-9428-8d0e2990ce15",
                        "name": "Deserunt dolore consequat",
                        "price": 473,
                        "stock": 25
                    },
                    {
                        "id": "591c4d35-8caa-4d77-8511-4de8d5af857d",
                        "name": "Laborum eiusmod cupidatat occaecat",
                        "price": 277,
                        "stock": 13
                    },
                    {
                        "id": "a3bf5734-2702-4c68-8eef-20d7e348d549",
                        "name": "Excepteur elit quis",
                        "price": 193,
                        "stock": 21
                    },
                    {
                        "id": "c93715b7-4368-4e0d-82d2-515a930ddc46",
                        "name": "Duis pariatur aliquip consectetur",
                        "price": 753,
                        "stock": 5
                    },
                    {
                        "id": "f715a7da-e233-470c-b687-2c4857f355ff",
                        "name": "Eiusmod excepteur incididunt",
                        "price": 389,
                        "stock": 23
                    }
                ]
            },
            {
                "id": "7875052d-b067-40ff-89f7-eead6bd4cb3d",
                "name": "Castleton",
                "products": [
                    {
                        "id": "bdad571d-b19b-47f0-bfb4-acb8e1fd4a35",
                        "name": "In non occaecat laborum",
                        "price": 232,
                        "stock": 9
                    },
                    {
                        "id": "806b16b5-75fa-404b-8d30-24804fe5dec3",
                        "name": "Nulla eu",
                        "price": 626,
                        "stock": 11
                    },
                    {
                        "id": "148ef400-11cd-404f-8c4f-81bbf8372003",
                        "name": "Quis in",
                        "price": 757,
                        "stock": 10
                    },
                    {
                        "id": "367c2f02-6efa-4b84-ab21-ea609a4f392a",
                        "name": "Minim ullamco dolore",
                        "price": 599,
                        "stock": 10
                    },
                    {
                        "id": "ed42412e-21a4-4fe0-ada8-3c647024ee3b",
                        "name": "Voluptate",
                        "price": 246,
                        "stock": 0
                    },
                    {
                        "id": "68042de5-325d-44bc-a023-d3735d35ffb5",
                        "name": "Proident labore exercitation sit",
                        "price": 117,
                        "stock": 28
                    },
                    {
                        "id": "41235166-02d0-46f9-8a74-1d2777d579ed",
                        "name": "Aute",
                        "price": 508,
                        "stock": 4
                    },
                    {
                        "id": "c50a5eec-35f1-4d74-9c2a-e4e8d048f38a",
                        "name": "Ullamco mollit voluptate",
                        "price": 376,
                        "stock": 8
                    },
                    {
                        "id": "efd8cb4e-e479-440e-90a9-ad2aa382863c",
                        "name": "Veniam",
                        "price": 564,
                        "stock": 15
                    },
                    {
                        "id": "7364ac1b-0439-4414-8f3d-aa9739f4fc9e",
                        "name": "Elit",
                        "price": 244,
                        "stock": 22
                    },
                    {
                        "id": "e7de0932-bcda-486b-ac5f-b9755871267b",
                        "name": "Fugiat",
                        "price": 768,
                        "stock": 10
                    },
                    {
                        "id": "5765625f-1c34-47df-ba6a-e3a62156a70a",
                        "name": "Quis sunt",
                        "price": 46,
                        "stock": 18
                    },
                    {
                        "id": "ec9dfc8f-24ca-4b5a-ab72-bd70004d9a02",
                        "name": "Mollit laborum",
                        "price": 357,
                        "stock": 22
                    },
                    {
                        "id": "4e1849ac-dc19-449e-8def-fc3291df9052",
                        "name": "Quis tempor consequat consequat",
                        "price": 170,
                        "stock": 29
                    },
                    {
                        "id": "bfc68341-6130-4cb2-9a52-39d7ad130b4f",
                        "name": "Irure minim",
                        "price": 27,
                        "stock": 23
                    }
                ]
            },
            {
                "id": "59f0e681-b866-46cd-ae3d-bd084ff01534",
                "name": "Groveville",
                "products": [
                    {
                        "id": "a37e4adb-7909-44ce-a2e0-e35561014522",
                        "name": "Incididunt consectetur non voluptate",
                        "price": 104,
                        "stock": 11
                    },
                    {
                        "id": "d2aeaa3b-18aa-455b-8d95-2770db066ec4",
                        "name": "Et reprehenderit est reprehenderit",
                        "price": 496,
                        "stock": 17
                    },
                    {
                        "id": "9c8ae49f-b214-473a-8ca1-90f902ad4754",
                        "name": "Irure",
                        "price": 542,
                        "stock": 28
                    },
                    {
                        "id": "a5af4298-69c4-4fa5-8cfb-738254c5b10d",
                        "name": "Enim ullamco",
                        "price": 99,
                        "stock": 0
                    },
                    {
                        "id": "c7f18718-4e5e-48c7-96b3-d3bf7e4dc01b",
                        "name": "Elit sint in",
                        "price": 507,
                        "stock": 30
                    },
                    {
                        "id": "fd797038-e675-4714-b1f2-3915e01a94ee",
                        "name": "Anim",
                        "price": 615,
                        "stock": 4
                    },
                    {
                        "id": "76ffef85-bc64-42f7-b882-8a0c9c22de16",
                        "name": "Ad ullamco anim",
                        "price": 597,
                        "stock": 23
                    },
                    {
                        "id": "79426246-035b-4371-8a2f-677fd21b44e9",
                        "name": "Amet",
                        "price": 658,
                        "stock": 20
                    },
                    {
                        "id": "2cde1a81-f0db-4f58-a04e-92ce328532ac",
                        "name": "Eu proident",
                        "price": 639,
                        "stock": 13
                    },
                    {
                        "id": "760decf4-59ac-4f47-a7f9-dab9590ca49d",
                        "name": "Anim sunt cillum ea",
                        "price": 781,
                        "stock": 27
                    },
                    {
                        "id": "7a3a7d5d-18ab-4f27-9f0f-278ab6bbaee6",
                        "name": "Ea",
                        "price": 787,
                        "stock": 8
                    },
                    {
                        "id": "e7102b8a-042b-4488-a62b-00ce43464ecd",
                        "name": "Velit dolore ipsum",
                        "price": 494,
                        "stock": 17
                    }
                ]
            },
            {
                "id": "86dc4ee3-6f51-42e2-80d7-04de7d0507d1",
                "name": "Rivera",
                "products": [
                    {
                        "id": "5b463365-a898-4e48-a669-f77ffaec94c9",
                        "name": "Proident",
                        "price": 550,
                        "stock": 22
                    },
                    {
                        "id": "4ebfba6b-3b80-422b-b27b-0e3f59151548",
                        "name": "Commodo",
                        "price": 214,
                        "stock": 18
                    },
                    {
                        "id": "5534cd13-e8c4-4777-bd9b-8484e2b104f1",
                        "name": "Ipsum ipsum",
                        "price": 410,
                        "stock": 4
                    },
                    {
                        "id": "19fc7136-779c-443e-b170-f072889d06f4",
                        "name": "Commodo",
                        "price": 733,
                        "stock": 5
                    },
                    {
                        "id": "35961313-282a-4fdd-a283-d91cae848ad2",
                        "name": "Mollit",
                        "price": 349,
                        "stock": 21
                    },
                    {
                        "id": "ee83aabf-de23-417f-b7b9-52b471ad1c31",
                        "name": "Amet esse amet ex",
                        "price": 678,
                        "stock": 2
                    }
                ]
            },
            {
                "id": "2d447b94-2a94-4512-8b25-59823d009ec2",
                "name": "Shepardsville",
                "products": [
                    {
                        "id": "9e198a84-8a56-41c0-b088-8043011fb9a5",
                        "name": "Ad amet velit sunt",
                        "price": 221,
                        "stock": 19
                    },
                    {
                        "id": "32f72b26-dd9e-4ee7-946f-972d33dabb4f",
                        "name": "Ea sint deserunt",
                        "price": 690,
                        "stock": 20
                    },
                    {
                        "id": "decf82c1-6b4b-41fd-9ee9-a8b68614bf4b",
                        "name": "Minim in",
                        "price": 142,
                        "stock": 18
                    },
                    {
                        "id": "3771b75a-1e21-4ae9-a8b0-6f22e9abddf9",
                        "name": "Consequat deserunt eiusmod pariatur",
                        "price": 760,
                        "stock": 28
                    },
                    {
                        "id": "105c1c11-cd7b-42e2-a125-49163c6f193e",
                        "name": "Deserunt qui consequat",
                        "price": 196,
                        "stock": 2
                    },
                    {
                        "id": "8fe2825e-50da-412b-b0ca-131b8a2771d9",
                        "name": "Proident non Lorem dolore",
                        "price": 387,
                        "stock": 16
                    },
                    {
                        "id": "00c1b1bc-e7b7-4e34-9574-49d5f65c0a47",
                        "name": "Excepteur",
                        "price": 504,
                        "stock": 15
                    },
                    {
                        "id": "6205b809-8376-4ddf-b5b2-dff38ad6edbd",
                        "name": "Eu",
                        "price": 206,
                        "stock": 9
                    }
                ]
            }
        ];
    }
}
