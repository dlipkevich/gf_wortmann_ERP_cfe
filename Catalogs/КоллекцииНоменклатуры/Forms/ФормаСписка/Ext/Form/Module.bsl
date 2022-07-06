﻿ #Область ОбработчикиСобытийФормы

&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	
	// ++ Галфинд_Домнышева_30_06_2022
	ТипПолеФормы = Тип("ПолеФормы");

	НовыйЭлемент = Элементы.Вставить("Код", ТипПолеФормы, Элементы.Список, ЭтаФорма.Элементы.ДатаНачалаЗакупок);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеНадписи;
	НовыйЭлемент.ПутьКДанным = "Список.Код";
	НовыйЭлемент.Заголовок = "Код"; 
		
    НовыйЭлемент = Элементы.Вставить("гф_Номер", ТипПолеФормы, Элементы.Список, ЭтаФорма.Элементы.ДатаНачалаЗакупок);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеНадписи;
	НовыйЭлемент.ПутьКДанным = "Список.гф_Номер";
	НовыйЭлемент.Заголовок = "Номер";

	Элементы.Переместить(ЭтаФорма.Элементы.Наименование, Элементы.Список, ЭтаФорма.Элементы.Список.ПодчиненныеЭлементы.гф_Номер);
	
	НовыйЭлемент = Элементы.Вставить("гф_Год", ТипПолеФормы, Элементы.Список, ЭтаФорма.Элементы.ДатаНачалаЗакупок);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеНадписи;
	НовыйЭлемент.ПутьКДанным = "Список.гф_Год";
	НовыйЭлемент.Заголовок = "Год";
	
	НовыйЭлемент = Элементы.Вставить("гф_ТехническийЛимит", ТипПолеФормы, Элементы.Список, ЭтаФорма.Элементы.ДатаНачалаЗакупок);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеНадписи;
	НовыйЭлемент.ПутьКДанным = "Список.гф_ТехническийЛимит";
	НовыйЭлемент.Заголовок = "Технический лимит";
	
	НовыйЭлемент = Элементы.Вставить("гф_ДатаНачалаФормированияЗаказов", ТипПолеФормы, Элементы.Список, ЭтаФорма.Элементы.ДатаНачалаЗакупок);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеНадписи;
	НовыйЭлемент.ПутьКДанным = "Список.гф_ДатаНачалаФормированияЗаказов";
	НовыйЭлемент.Заголовок = "Формирование заказов Начало"; 
	
	НовыйЭлемент = Элементы.Вставить("гф_ДатаОкончанияФормированияЗаказов", ТипПолеФормы, Элементы.Список, ЭтаФорма.Элементы.ДатаНачалаЗакупок);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеНадписи;
	НовыйЭлемент.ПутьКДанным = "Список.гф_ДатаОкончанияФормированияЗаказов";
	НовыйЭлемент.Заголовок = "Формирование заказов Окончание"; 
	
	НовыйЭлемент = Элементы.Вставить("гф_ДатаНачалаОтгрузкиЗаказов", ТипПолеФормы, Элементы.Список, ЭтаФорма.Элементы.ДатаНачалаЗакупок);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеНадписи;
	НовыйЭлемент.ПутьКДанным = "Список.гф_ДатаНачалаОтгрузкиЗаказов";
	НовыйЭлемент.Заголовок = "Отгрузка заказов Начало";
	
	НовыйЭлемент = Элементы.Вставить("гф_ДатаОкончанияОтгрузкиЗаказов", ТипПолеФормы, Элементы.Список, ЭтаФорма.Элементы.ДатаНачалаЗакупок);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеНадписи;
	НовыйЭлемент.ПутьКДанным = "Список.гф_ДатаОкончанияОтгрузкиЗаказов";
	НовыйЭлемент.Заголовок = "Отгрузка заказов Окончание";
	
	НовыйЭлемент = Элементы.Вставить("гф_ДатаОкончанияРедактированияСкидок", ТипПолеФормы, Элементы.Список, ЭтаФорма.Элементы.ДатаНачалаЗакупок);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеНадписи;
	НовыйЭлемент.ПутьКДанным = "Список.гф_ДатаОкончанияРедактированияСкидок";
	НовыйЭлемент.Заголовок = "Дата окончания редактирования скидок"; 
	
	НовыйЭлемент = Элементы.Вставить("гф_ДатаИзготовления", ТипПолеФормы, Элементы.Список, ЭтаФорма.Элементы.ДатаНачалаЗакупок);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеНадписи;
	НовыйЭлемент.ПутьКДанным = "Список.гф_ДатаИзготовления";
	НовыйЭлемент.Заголовок = "Дата изготовления"; 
    // -- Галфинд_Домнышева_30_06_2022

КонецПроцедуры

#КонецОбласти