﻿
&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	// #wortmann {
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=811fbcee7bda45d711ed290097fe6193
	// добавление реквизита на форму для отслежаивания статуса Номенклатуры в НК
	// Галфинд_Домнышева 2022/09/02
	ТипПолеФормы = Тип("ПолеФормы");
	НовыйЭлемент = Элементы.Добавить("гф_СостояниеВыгрузкиНоменклатуры", ТипПолеФормы, Элементы.Список);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеНадписи;
	НовыйЭлемент.ПутьКДанным = "Список.гф_СостояниеВыгрузкиНоменклатуры";
    // #wortmann {
КонецПроцедуры
