import { Injectable } from "@angular/core";
import Swal from 'sweetalert2';

@Injectable({
	providedIn: "root"
})
export class ToastService {

	constructor() { }


	//Toasts

	toast(msg: string = "", timer: number = 5000): void {
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

	toastSuccess(msg: string = ""): void {
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

	//Inputs

	async inputRSSModal() {
		const url = await Swal.fire({
			title: 'Enter RSS feed',
			input: 'url',
			inputPlaceholder: 'RSS feed...'
		})

		if (url) return url;
	}
}
