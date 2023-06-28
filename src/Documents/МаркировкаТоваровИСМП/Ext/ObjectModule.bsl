﻿
&После("ПередЗаписью")
Процедура ИК_ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если НЕ Отказ
		И РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		
		Отказ = ПроверитьПубликациюТоваров();
		Если Отказ Тогда
			Сообщить("Не все товары по документу опубликованы");	
		КонецЕсли;
	КонецЕсли; 
	
КонецПроцедуры

Функция ПроверитьПубликациюТоваров()
	
	ТЗТовары = Товары.Выгрузить();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	МаркировкаТоваровИСМПТовары.Номенклатура КАК Номенклатура,
		|	МаркировкаТоваровИСМПТовары.Характеристика КАК Характеристика
		|ПОМЕСТИТЬ ВТ_Товары
		|ИЗ
		|	&Товары КАК МаркировкаТоваровИСМПТовары
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_Товары.Номенклатура КАК Номенклатура,
		|	ВТ_Товары.Характеристика КАК Характеристика
		|ИЗ
		|	ВТ_Товары КАК ВТ_Товары
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
		|		ПО ВТ_Товары.Номенклатура = ШтрихкодыНоменклатуры.Номенклатура
		|			И ВТ_Товары.Характеристика = ШтрихкодыНоменклатуры.Характеристика
		|ГДЕ
		|	ШтрихкодыНоменклатуры.гф_СостояниеВыгрузкиНоменклатуры ЕСТЬ NULL
		|		ИЛИ ШтрихкодыНоменклатуры.гф_СостояниеВыгрузкиНоменклатуры <> ЗНАЧЕНИЕ(Перечисление.СостоянияВыгрузкиНоменклатуры.Принята)";
	
	Запрос.УстановитьПараметр("Товары", ТЗТовары);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат РезультатЗапроса.Пустой();
	
КонецФункции	