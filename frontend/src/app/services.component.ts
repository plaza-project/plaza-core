import { Component, OnInit } from '@angular/core';
import { Service } from './service';
import { ServiceService } from './service.service';
import { Router } from '@angular/router';

@Component({
    // moduleId: module.id,
    selector: 'my-services',
    templateUrl: './services.component.html',
    providers: [ServiceService]
})

export class ServicesComponent {
    services: Service[] = [];

    constructor(
        private serviceService: ServiceService,
        private router: Router,
    ) {
        this.serviceService = serviceService;
        this.router = router;
    }

    ngOnInit(): void {
        this.serviceService.getServices()
            .then(services => this.services = services);
    }

    addService() : void {
        this.router.navigate(['/services/add']);
    }
}