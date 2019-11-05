import { Injectable } from "@angular/core";
import Swal from 'sweetalert2';
import * as app from 'electron';
import * as log from 'electron-log';

@Injectable({
	providedIn: "root"
})
export class ToastService {

	constructor() { }

	toast(msg: string = "", timer: number = 5000): void {
		log.info("Toast service :: Showing toast => " + msg);
		Swal.fire({
			toast: true,
			text: msg,
			position: 'top-end',
			showConfirmButton: false,
			timer: timer,
			animation: true,
			customClass: {
				content: 'toast-content-class',
				popup: 'toast-popup-class'
			}
		})
	}

	toastURL(msg: string = "", url: string = "", timer: number = 5000): void {
		log.info("Toast service :: Showing toast => " + msg);
		Swal.fire({
			toast: true,
			text: msg,
			position: 'top-end',
			showConfirmButton: false,
			timer: timer,
			animation: true,
			customClass: {
				content: 'toast-content-class',
				popup: 'toast-popup-update-class'
			},
			onOpen: (toast) => {
				toast.addEventListener('click', () => {
					app.shell.openExternal(url);
				})
			}
		})
	}

	toastSuccess(msg: string = ""): void {
		log.info("Toast service :: Showing success toast => " + msg);
		Swal.fire({
			toast: true,
			type: 'success',
			text: msg,
			position: 'top-end',
			showConfirmButton: false,
			timer: 5000,
			animation: true,
			customClass: {
				content: 'toast-content-class',
				popup: 'toast-popup-class'
			}
		})
	}

	toastError(msg: string = ""): void {
		log.info("Toast service :: Showing error toast => " + msg);
		Swal.fire({
			toast: true,
			type: 'error',
			text: msg,
			position: 'top-end',
			showConfirmButton: false,
			timer: 5000,
			animation: true,
			customClass: {
				content: 'toast-content-class',
				popup: 'toast-popup-class'
			}
		})
	}

	//Modals

	modal(title: string = "", msg: string = ""): void {
		log.info("Toast service :: Showing modal.");
		Swal.fire({
			title: title,
			text: msg,
			showConfirmButton: false,
			customClass: {
				content: 'modal-content-class',
				popup: 'modal-popup-class',
				title: 'modal-title-class'
			}
		});
	}

	successModal(msg: string = ""): void {
		log.info("Toast service :: Showing success modal.");
		Swal.fire({
			type: 'success',
			text: msg,
			showConfirmButton: false,
			customClass: {
				content: 'modal-content-class',
				popup: 'modal-popup-class',
				title: 'modal-title-class'
			}
		});
	}

	errorModal(error: string = "Something went wrong."): void {
		log.info("Toast service :: Showing error modal.");
		Swal.fire({
			type: 'error',
			text: error,
			showConfirmButton: false,
			customClass: {
				content: 'modal-content-class',
				popup: 'modal-popup-class',
				title: 'modal-title-class'
			}
		});
	}

	// Confirmation
	async confirmModal() {
		const response = await Swal.fire({
			title: 'Are you sure?',
			type: 'warning',
			showCancelButton: true,
			confirmButtonText: 'Yes, remove it!',
			customClass: {
				content: 'modal-content-class',
				popup: 'modal-popup-class',
				title: 'modal-title-class'
			}
		});
		if (response) return response;
	}

	//Inputs
	async inputRSSModal() {
		log.info("Toast service :: Showing input modal.");
		const url = await Swal.fire({
			title: 'Enter RSS feed',
			input: 'url',
			inputPlaceholder: 'RSS feed...'
		})
		if (url) return url;
	}
}
