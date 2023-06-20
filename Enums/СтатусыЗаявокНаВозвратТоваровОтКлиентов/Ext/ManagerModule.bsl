﻿
&ИзменениеИКонтроль("ЗаполнитьСписокВыбора")
Процедура гф_ЗаполнитьСписокВыбора(ДанныеВыбора, УстановленныйСтатус)
	Если НЕ ПолучитьФункциональнуюОпцию("ИспользоватьРасширенныеВозможностиЗаказаКлиента") Тогда
		Возврат
	КонецЕсли;

	ДанныеВыбора.Очистить();

	ДанныеВыбора.Добавить(Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.НеСогласована);
	ДанныеВыбора.Добавить(Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.КВозврату);
	Если НЕ ПолучитьФункциональнуюОпцию("ИспользоватьПострочнуюОтгрузкуВЗаказеКлиента") Тогда
		ДанныеВыбора.Добавить(Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.КОбеспечению, НСтр("ru = 'В резерве';
		|en = 'In reserve'"));
		ДанныеВыбора.Добавить(Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.КОтгрузке);
	Иначе
		ДанныеВыбора.Добавить(Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.КОбеспечению, НСтр("ru = 'К выполнению';
		|en = 'For completion'"));
	КонецЕсли;
    #Вставка
	// #wortmann { 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8ea8b083fed1320811ee039fa56b96bb
	// Галфинд_Домнышева 2023/06/13
	ДанныеВыбора.Добавить(Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.гф_УКДПодписан);// Добавлено Галфинд_ДомнышеваКР_20_06_2023
	ДанныеВыбора.Добавить(Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.гф_КМПроверены);
	ДанныеВыбора.Добавить(Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.гф_ЗаявкаПереданаВРМК);
	ДанныеВыбора.Добавить(Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.гф_ТоварПеремаркирован);
	// } #wortmann
	#КонецВставки
	
	Если ПолучитьФункциональнуюОпцию("НеЗакрыватьЗаказыКлиентовБезПолнойОплаты")
		ИЛИ ПолучитьФункциональнуюОпцию("НеЗакрыватьЗаказыКлиентовБезПолнойОтгрузки") Тогда
		ДанныеВыбора.Добавить(Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.Выполнена);
	КонецЕсли;
	ДанныеВыбора.Добавить(Перечисления.СтатусыЗаявокНаВозвратТоваровОтКлиентов.Отклонена);

	Если ДанныеВыбора.НайтиПоЗначению(УстановленныйСтатус) = Неопределено Тогда

		ДанныеВыбора.Вставить(ДанныеВыбора.Количество() - 2, УстановленныйСтатус, УстановленныйСтатус);

	КонецЕсли;

КонецПроцедуры
