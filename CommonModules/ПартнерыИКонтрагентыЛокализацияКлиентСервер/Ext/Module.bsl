﻿
&ИзменениеИКонтроль("РеквизитыОбъектаКонтрагента")
Функция гф_РеквизитыОбъектаКонтрагента(Форма)

	СтруктураРеквизитов = Новый Структура;
	СтруктураРеквизитов.Вставить("ЭтоФормаПомощника", СтрНайти(Форма.ИмяФормы, "ПомощникНового") > 0);
	СтруктураРеквизитов.Вставить("ЭтоФормаПартнера", Не СтрНайти(Форма.ИмяФормы, "Контрагенты") > 0);
	СтруктураРеквизитов.Вставить("ЭтоФормаКонтрагента", СтрНайти(Форма.ИмяФормы, "Контрагенты") > 0);

	Если СтруктураРеквизитов.ЭтоФормаПомощника Тогда
		СтруктураРеквизитов.Вставить("ЮрФизЛицо", ТипЮрФизЛицаКонтрагента(Форма.ЭтоКомпания, Форма.ВидКомпании));
		СтруктураРеквизитов.Вставить("ИНН", Форма.ИНН);
		СтруктураРеквизитов.Вставить("ПутьКИНН", "ИНН");
		СтруктураРеквизитов.Вставить("КПП", Форма.КПП);
		СтруктураРеквизитов.Вставить("ПутьКПП", "КПП");
		СтруктураРеквизитов.Вставить("КодПоОКПО", Форма.КодПоОКПО);
		СтруктураРеквизитов.Вставить("ПутьКодПоОКПО", "КодПоОКПО");
		СтруктураРеквизитов.Вставить("ОбособленноеПодразделение", Форма.ВидКомпании = 3);
		СтруктураРеквизитов.Вставить("ГоловнойКонтрагент", Форма.ГоловнойКонтрагент);
		СтруктураРеквизитов.Вставить("НДСПоСтавкам4и2", Ложь);
	ИначеЕсли СтруктураРеквизитов.ЭтоФормаПартнера Тогда
		СтруктураРеквизитов.Вставить("ЮрФизЛицо", Форма.ЮрФизЛицо);
		СтруктураРеквизитов.Вставить("ИНН", Форма.ИНН);
		СтруктураРеквизитов.Вставить("ПутьКИНН", "ИНН");
		СтруктураРеквизитов.Вставить("КПП", Форма.КПП);
		СтруктураРеквизитов.Вставить("ПутьКПП", "КПП");
		СтруктураРеквизитов.Вставить("КодПоОКПО", Форма.КодПоОКПО);
		СтруктураРеквизитов.Вставить("ПутьКодПоОКПО", "КодПоОКПО");
		СтруктураРеквизитов.Вставить("ОбособленноеПодразделение", Форма.ОбособленноеПодразделение);
		СтруктураРеквизитов.Вставить("ГоловнойКонтрагент", Форма.ГоловнойКонтрагент);
		СтруктураРеквизитов.Вставить("НДСПоСтавкам4и2", Форма.НДСПоСтавкам4и2);
	Иначе
		Объект = Форма.Объект;
		СтруктураРеквизитов.Вставить("ЮрФизЛицо", Объект.ЮрФизЛицо);
		СтруктураРеквизитов.Вставить("ИНН", Объект.ИНН);
		СтруктураРеквизитов.Вставить("ПутьКИНН", "Объект.ИНН");
		СтруктураРеквизитов.Вставить("КПП", Объект.КПП);
		СтруктураРеквизитов.Вставить("ПутьКПП", "Объект.КПП");
		СтруктураРеквизитов.Вставить("КодПоОКПО", Объект.КодПоОКПО);
		СтруктураРеквизитов.Вставить("ПутьКодПоОКПО", "Объект.КодПоОКПО");
		СтруктураРеквизитов.Вставить("ОбособленноеПодразделение", Объект.ОбособленноеПодразделение);
		СтруктураРеквизитов.Вставить("ГоловнойКонтрагент", Объект.ГоловнойКонтрагент);
		СтруктураРеквизитов.Вставить("НДСПоСтавкам4и2", Объект.НДСПоСтавкам4и2);
#Вставка		
		СтруктураРеквизитов.Вставить("гф_ОсновнойКонтрагент", Форма.гф_ОсновнойКонтрагент);
#КонецВставки
	КонецЕсли;

	Возврат СтруктураРеквизитов

КонецФункции
